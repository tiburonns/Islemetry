import CoreLocation
import Foundation
import Network
import UIKit

@MainActor
final class DeviceTelemetryStore: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let backgroundLocationKey = "location.backgroundEnabled"

    @Published private(set) var metrics: [DeviceMetric] = []
    @Published private(set) var lastUpdated: Date = .distantPast
    @Published private(set) var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var backgroundLocationEnabled: Bool
    @Published private(set) var weatherAttributionURL = URL(string: "https://open-meteo.com/")
    @Published private(set) var weatherServiceName = "Open-Meteo"
    @Published private(set) var weatherStatusMessage: String?

    private enum NetworkInterface {
        case checking
        case offline
        case wifi
        case cellular
        case ethernet
        case other
    }

    private var networkInterface: NetworkInterface = .checking
    private var networkConstrained = false
    private var networkExpensive = false
    private var networkSupportsIPv4 = false
    private var networkSupportsIPv6 = false
    private var networkSupportsDNS = false

    private var localTemperatureValue: String?
    private var feelsLikeValue: String?
    private var lastWeatherCode: Int?
    private var lastWeatherIsDay = true
    private var weatherSymbolName = "cloud.sun.fill"
    private var locationValue: String?
    private var lastWeatherFetchAt: Date?
    private var lastWeatherLocation: CLLocation?
    private var pendingForcedWeatherRefresh = false
    private var weatherRefreshInFlight = false
    private var requestedAlwaysAuthorizationThisSession = false

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.tiburonns.islemetry.network")
    private let locationManager = CLLocationManager()
    private var systemObservers: [NSObjectProtocol] = []

    override init() {
        backgroundLocationEnabled = UserDefaults.standard.bool(
            forKey: Self.backgroundLocationKey
        )

        super.init()

        UIDevice.current.isBatteryMonitoringEnabled = true

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 2_000
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.showsBackgroundLocationIndicator = true

        locationAuthorizationStatus = locationManager.authorizationStatus

        startSystemObservers()
        startNetworkMonitor()
        refresh()
    }

    deinit {
        pathMonitor.cancel()
        locationManager.stopUpdatingLocation()
        systemObservers.forEach(NotificationCenter.default.removeObserver)
    }

    private func startSystemObservers() {
        let center = NotificationCenter.default
        let names: [Notification.Name] = [
            UIDevice.batteryLevelDidChangeNotification,
            UIDevice.batteryStateDidChangeNotification,
            Notification.Name.NSProcessInfoPowerStateDidChange,
            ProcessInfo.thermalStateDidChangeNotification,
            UIScreen.brightnessDidChangeNotification
        ]

        systemObservers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.refresh()
                }
            }
        }
    }

    func prepareLocationWeather() {
        locationAuthorizationStatus = locationManager.authorizationStatus

        if backgroundLocationEnabled {
            configureBackgroundLocation()
        } else if isLocationAuthorized {
            locationManager.requestLocation()
        }

    }

    func requestLocationAccess() {
        guard CLLocationManager.locationServicesEnabled() else {
            weatherStatusMessage = AppLanguage.current.text(
                "Location Services are disabled.",
                "Los Servicios de localización están desactivados."
            )
            refresh()
            return
        }

        locationAuthorizationStatus = locationManager.authorizationStatus

        switch locationAuthorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            refreshLocationWeather(force: true)

        case .denied, .restricted:
            weatherStatusMessage = AppLanguage.current.text(
                "Location access is not available. Enable it in Settings.",
                "El acceso a la ubicación no está disponible. Actívalo en Configuración."
            )
            refresh()

        @unknown default:
            break
        }
    }

    func setBackgroundLocationEnabled(_ enabled: Bool) {
        backgroundLocationEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: Self.backgroundLocationKey)

        if enabled {
            configureBackgroundLocation()
        } else {
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.stopUpdatingLocation()

            if isLocationAuthorized {
                locationManager.requestLocation()
            }
        }

        refresh()
    }

    func refreshLocationWeather(force: Bool = true) {
        guard isLocationAuthorized else {
            requestLocationAccess()
            return
        }

        pendingForcedWeatherRefresh = force

        if backgroundLocationEnabled {
            configureBackgroundLocation()
        } else {
            locationManager.requestLocation()
        }
    }

    func locationAuthorizationDescription(language: AppLanguage) -> String {
        switch locationAuthorizationStatus {
        case .notDetermined:
            return language.text("Not requested", "No solicitado")
        case .restricted:
            return language.text("Restricted", "Restringido")
        case .denied:
            return language.text("Denied", "Denegado")
        case .authorizedAlways:
            return language.text("Always", "Siempre")
        case .authorizedWhenInUse:
            return language.text("While Using", "Al usar la app")
        @unknown default:
            return language.text("Unknown", "Desconocido")
        }
    }

    func refresh() {
        let now = Date()
        let language = AppLanguage.current
        let processInfo = ProcessInfo.processInfo
        let device = UIDevice.current
        let screen = UIScreen.main

        let batteryLevel = device.batteryLevel >= 0 ? Int((device.batteryLevel * 100).rounded()) : nil
        let memory = ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .memory)
        let storage = storageValues(language: language)
        let refreshRate = screen.maximumFramesPerSecond
        let brightness = Int((screen.brightness * 100).rounded())
        let resolution = "\(Int(screen.nativeBounds.width))×\(Int(screen.nativeBounds.height)) px"
        let displayScale = String(format: "%.2f×", screen.nativeScale)

        let weatherUnavailable = weatherStatusMessage
            ?? language.text("Waiting for location", "Esperando ubicación")
        let localizedWeatherCondition = lastWeatherCode.map {
            Self.weatherDescription(code: $0, language: language)
        }

        metrics = [
            DeviceMetric(kind: .battery, title: language.text("Battery", "Batería"), value: batteryLevel.map { "\($0)%" } ?? language.text("Unknown", "Desconocido"), symbol: batterySymbol(level: batteryLevel), updatedAt: now),
            DeviceMetric(kind: .charging, title: language.text("Power", "Energía"), value: chargingDescription(device.batteryState, language: language), symbol: "bolt.fill", updatedAt: now),
            DeviceMetric(kind: .lowPower, title: language.text("Low Power", "Bajo consumo"), value: booleanDescription(processInfo.isLowPowerModeEnabled, language: language), symbol: "leaf.fill", updatedAt: now),
            DeviceMetric(kind: .thermal, title: language.text("Thermal", "Térmico"), value: thermalDescription(processInfo.thermalState, language: language), symbol: "thermometer.medium", updatedAt: now),
            DeviceMetric(kind: .memory, title: language.text("Memory Total", "Memoria total"), value: memory, symbol: "memorychip", updatedAt: now),
            DeviceMetric(kind: .storage, title: language.text("Storage", "Almacenamiento"), value: storage.summary, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .storageFree, title: language.text("Storage Free", "Almacenamiento libre"), value: storage.free, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .storageUsed, title: language.text("Storage Used", "Almacenamiento usado"), value: storage.used, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .storageTotal, title: language.text("Storage Total", "Almacenamiento total"), value: storage.total, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .cpuCores, title: language.text("CPU Cores", "Núcleos de CPU"), value: "\(processInfo.processorCount)", symbol: "cpu", updatedAt: now),
            DeviceMetric(kind: .activeCpuCores, title: language.text("Active Cores", "Núcleos activos"), value: "\(processInfo.activeProcessorCount)", symbol: "cpu", updatedAt: now),
            DeviceMetric(kind: .refreshRate, title: language.text("Refresh Rate", "Frecuencia"), value: language.text("\(refreshRate) Hz max", "\(refreshRate) Hz máx."), symbol: "rectangle.inset.filled", updatedAt: now),
            DeviceMetric(kind: .promotion, title: "ProMotion", value: refreshRate > 60 ? language.text("Up to \(refreshRate) Hz", "Hasta \(refreshRate) Hz") : language.text("Not available", "No disponible"), symbol: "speedometer", updatedAt: now),
            DeviceMetric(kind: .displayResolution, title: language.text("Resolution", "Resolución"), value: resolution, symbol: "rectangle", updatedAt: now),
            DeviceMetric(kind: .displayScale, title: language.text("Display Scale", "Escala de pantalla"), value: displayScale, symbol: "arrow.up.left.and.arrow.down.right", updatedAt: now),
            DeviceMetric(kind: .brightness, title: language.text("Brightness", "Brillo"), value: "\(brightness)%", symbol: "sun.max.fill", updatedAt: now),
            DeviceMetric(kind: .network, title: language.text("Network", "Red"), value: networkDescription(language: language), symbol: networkSymbol(), updatedAt: now),
            DeviceMetric(kind: .lowDataMode, title: language.text("Low Data", "Datos reducidos"), value: booleanDescription(networkConstrained, language: language), symbol: "tortoise.fill", updatedAt: now),
            DeviceMetric(kind: .networkExpensive, title: language.text("Network Cost", "Costo de red"), value: networkExpensive ? language.text("Expensive", "Costosa") : language.text("Normal", "Normal"), symbol: "antenna.radiowaves.left.and.right", updatedAt: now),
            DeviceMetric(kind: .ipv4, title: "IPv4", value: supportDescription(networkSupportsIPv4, language: language), symbol: "4.circle.fill", updatedAt: now),
            DeviceMetric(kind: .ipv6, title: "IPv6", value: supportDescription(networkSupportsIPv6, language: language), symbol: "6.circle.fill", updatedAt: now),
            DeviceMetric(kind: .dns, title: "DNS", value: supportDescription(networkSupportsDNS, language: language), symbol: "network", updatedAt: now),
            DeviceMetric(kind: .device, title: language.text("Hardware", "Hardware"), value: Self.hardwareIdentifier, symbol: "iphone", updatedAt: now),
            DeviceMetric(kind: .deviceModel, title: language.text("Device Model", "Modelo del dispositivo"), value: device.localizedModel, symbol: "iphone", updatedAt: now),
            DeviceMetric(kind: .system, title: language.text("System", "Sistema"), value: "\(device.systemName) \(device.systemVersion)", symbol: "gear", updatedAt: now),
            DeviceMetric(kind: .locale, title: language.text("Locale", "Configuración regional"), value: Locale.current.identifier, symbol: "globe", updatedAt: now),
            DeviceMetric(kind: .timeZone, title: language.text("Time Zone", "Zona horaria"), value: TimeZone.current.identifier, symbol: "clock", updatedAt: now),
            DeviceMetric(kind: .localTemperature, title: language.text("Local Temperature", "Temperatura local"), value: localTemperatureValue ?? weatherUnavailable, symbol: weatherSymbolName, updatedAt: now),
            DeviceMetric(kind: .feelsLike, title: language.text("Feels Like", "Sensación térmica"), value: feelsLikeValue ?? weatherUnavailable, symbol: "thermometer.medium", updatedAt: now),
            DeviceMetric(kind: .weatherCondition, title: language.text("Weather", "Clima"), value: localizedWeatherCondition ?? weatherUnavailable, symbol: weatherSymbolName, updatedAt: now),
            DeviceMetric(kind: .location, title: language.text("Location", "Ubicación"), value: locationValue ?? locationAuthorizationDescription(language: language), symbol: "location.fill", updatedAt: now)
        ]

        lastUpdated = now
    }

    private var isLocationAuthorized: Bool {
        locationAuthorizationStatus == .authorizedAlways
            || locationAuthorizationStatus == .authorizedWhenInUse
    }

    private func configureBackgroundLocation() {
        locationAuthorizationStatus = locationManager.authorizationStatus

        switch locationAuthorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse:
            if !requestedAlwaysAuthorizationThisSession {
                requestedAlwaysAuthorizationThisSession = true
                locationManager.requestAlwaysAuthorization()
            }
            locationManager.requestLocation()

        case .authorizedAlways:
            startBackgroundLocationUpdates()

        case .denied, .restricted:
            weatherStatusMessage = AppLanguage.current.text(
                "Background location requires location permission.",
                "La ubicación en segundo plano requiere permiso de ubicación."
            )

        @unknown default:
            break
        }
    }

    private func startBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            if backgroundLocationEnabled,
               !requestedAlwaysAuthorizationThisSession {
                requestedAlwaysAuthorizationThisSession = true
                manager.requestAlwaysAuthorization()
            }
            manager.requestLocation()

        case .authorizedAlways:
            if backgroundLocationEnabled {
                startBackgroundLocationUpdates()
            } else {
                manager.requestLocation()
            }

        case .denied, .restricted:
            manager.stopUpdatingLocation()
            weatherStatusMessage = AppLanguage.current.text(
                "Location access is unavailable.",
                "El acceso a la ubicación no está disponible."
            )
            refresh()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        locationValue = String(
            format: "%.3f°, %.3f°",
            location.coordinate.latitude,
            location.coordinate.longitude
        )

        let force = pendingForcedWeatherRefresh
        pendingForcedWeatherRefresh = false

        Task {
            await updateWeather(for: location, force: force)
        }

        if !backgroundLocationEnabled {
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        if let locationError = error as? CLError,
           locationError.code == .locationUnknown {
            return
        }

        weatherStatusMessage = error.localizedDescription
        refresh()
    }

    private func updateWeather(for location: CLLocation, force: Bool) async {
        if weatherRefreshInFlight {
            return
        }

        if !force,
           let lastWeatherFetchAt,
           let lastWeatherLocation,
           Date().timeIntervalSince(lastWeatherFetchAt) < 15 * 60,
           location.distance(from: lastWeatherLocation) < 5_000 {
            refresh()
            return
        }

        weatherRefreshInFlight = true
        defer { weatherRefreshInFlight = false }

        do {
            let current = try await fetchOpenMeteoCurrentWeather(for: location)

            localTemperatureValue = Self.temperatureString(current.temperature2M)
            feelsLikeValue = Self.temperatureString(current.apparentTemperature)
            lastWeatherCode = current.weatherCode
            lastWeatherIsDay = current.isDay == 1
            weatherSymbolName = Self.weatherSymbol(
                code: current.weatherCode,
                isDay: lastWeatherIsDay
            )
            lastWeatherFetchAt = Date()
            lastWeatherLocation = location
            weatherStatusMessage = nil

            refresh()
            await pushWeatherSnapshotToLiveActivity()
        } catch {
            weatherStatusMessage = error.localizedDescription
            refresh()
        }
    }

    private struct OpenMeteoResponse: Decodable {
        let current: Current

        struct Current: Decodable {
            let temperature2M: Double
            let apparentTemperature: Double
            let weatherCode: Int
            let isDay: Int

            enum CodingKeys: String, CodingKey {
                case temperature2M = "temperature_2m"
                case apparentTemperature = "apparent_temperature"
                case weatherCode = "weather_code"
                case isDay = "is_day"
            }
        }
    }

    private func fetchOpenMeteoCurrentWeather(
        for location: CLLocation
    ) async throws -> OpenMeteoResponse.Current {
        var components = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "latitude",
                value: String(format: "%.5f", location.coordinate.latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(format: "%.5f", location.coordinate.longitude)
            ),
            URLQueryItem(
                name: "current",
                value: "temperature_2m,apparent_temperature,weather_code,is_day"
            ),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder()
            .decode(OpenMeteoResponse.self, from: data)
            .current
    }

    private func pushWeatherSnapshotToLiveActivity() async {
        let manager = LiveActivityManager()
        await manager.update(
            with: metrics,
            configuration: .current
        )
    }

    private static func temperatureString(_ celsius: Double) -> String {
        String(format: "%.0f °C", celsius)
    }

    private static func weatherDescription(
        code: Int,
        language: AppLanguage
    ) -> String {
        switch code {
        case 0:
            return language.text("Clear", "Despejado")
        case 1:
            return language.text("Mostly clear", "Mayormente despejado")
        case 2:
            return language.text("Partly cloudy", "Parcialmente nublado")
        case 3:
            return language.text("Cloudy", "Nublado")
        case 45, 48:
            return language.text("Fog", "Niebla")
        case 51, 53, 55:
            return language.text("Drizzle", "Llovizna")
        case 56, 57:
            return language.text("Freezing drizzle", "Llovizna helada")
        case 61, 63, 65:
            return language.text("Rain", "Lluvia")
        case 66, 67:
            return language.text("Freezing rain", "Lluvia helada")
        case 71, 73, 75, 77:
            return language.text("Snow", "Nieve")
        case 80, 81, 82:
            return language.text("Rain showers", "Chubascos")
        case 85, 86:
            return language.text("Snow showers", "Chubascos de nieve")
        case 95:
            return language.text("Thunderstorm", "Tormenta")
        case 96, 99:
            return language.text("Thunderstorm with hail", "Tormenta con granizo")
        default:
            return language.text("Weather", "Clima")
        }
    }

    private static func weatherSymbol(code: Int, isDay: Bool) -> String {
        switch code {
        case 0:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1, 2:
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 56, 57, 66, 67:
            return "cloud.sleet.fill"
        case 61, 63, 65, 80, 81, 82:
            return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86:
            return "cloud.snow.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.sun.fill"
        }
    }

    private func startNetworkMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let interface: NetworkInterface

            if path.status != .satisfied {
                interface = .offline
            } else if path.usesInterfaceType(.wifi) {
                interface = .wifi
            } else if path.usesInterfaceType(.cellular) {
                interface = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                interface = .ethernet
            } else {
                interface = .other
            }

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.networkInterface = interface
                self.networkConstrained = path.isConstrained
                self.networkExpensive = path.isExpensive
                self.networkSupportsIPv4 = path.supportsIPv4
                self.networkSupportsIPv6 = path.supportsIPv6
                self.networkSupportsDNS = path.supportsDNS
                self.refresh()
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    private func storageValues(language: AppLanguage) -> (summary: String, free: String, used: String, total: String) {
        do {
            let values = try URL(fileURLWithPath: NSHomeDirectory()).resourceValues(
                forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]
            )

            guard let total = values.volumeTotalCapacity,
                  let available = values.volumeAvailableCapacity else {
                let unknown = language.text("Unknown", "Desconocido")
                return (unknown, unknown, unknown, unknown)
            }

            let used = max(total - available, 0)
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file

            let freeString = formatter.string(fromByteCount: Int64(available))
            let usedString = formatter.string(fromByteCount: Int64(used))
            let totalString = formatter.string(fromByteCount: Int64(total))

            return (
                language.text("\(freeString) free / \(totalString)", "\(freeString) libres / \(totalString)"),
                freeString,
                usedString,
                totalString
            )
        } catch {
            let unavailable = language.text("Unavailable", "No disponible")
            return (unavailable, unavailable, unavailable, unavailable)
        }
    }

    private func batterySymbol(level: Int?) -> String {
        guard let level else { return "battery.0percent" }
        switch level {
        case 76...100: return "battery.100percent"
        case 51...75: return "battery.75percent"
        case 26...50: return "battery.50percent"
        case 1...25: return "battery.25percent"
        default: return "battery.0percent"
        }
    }

    private func chargingDescription(_ state: UIDevice.BatteryState, language: AppLanguage) -> String {
        switch state {
        case .charging: return language.text("Charging", "Cargando")
        case .full: return language.text("Full", "Completa")
        case .unplugged: return language.text("On battery", "Usando batería")
        case .unknown: return language.text("Unknown", "Desconocido")
        @unknown default: return language.text("Unknown", "Desconocido")
        }
    }

    private func thermalDescription(_ state: ProcessInfo.ThermalState, language: AppLanguage) -> String {
        switch state {
        case .nominal: return language.text("Nominal", "Nominal")
        case .fair: return language.text("Fair", "Moderado")
        case .serious: return language.text("Serious", "Serio")
        case .critical: return language.text("Critical", "Crítico")
        @unknown default: return language.text("Unknown", "Desconocido")
        }
    }

    private func booleanDescription(_ value: Bool, language: AppLanguage) -> String {
        value ? language.text("On", "Activado") : language.text("Off", "Desactivado")
    }

    private func supportDescription(_ supported: Bool, language: AppLanguage) -> String {
        supported ? language.text("Supported", "Compatible") : language.text("Unavailable", "No disponible")
    }

    private func networkDescription(language: AppLanguage) -> String {
        switch networkInterface {
        case .checking:
            return language.text("Checking…", "Revisando…")
        case .offline:
            return language.text("Offline", "Sin conexión")
        case .wifi:
            return networkConstrained ? language.text("Wi-Fi · Low Data", "Wi-Fi · Datos reducidos") : "Wi-Fi"
        case .cellular:
            return networkConstrained ? language.text("Cellular · Low Data", "Celular · Datos reducidos") : language.text("Cellular", "Celular")
        case .ethernet:
            return "Ethernet"
        case .other:
            return language.text("Connected", "Conectado")
        }
    }

    private func networkSymbol() -> String {
        switch networkInterface {
        case .wifi: return "wifi"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .offline: return "wifi.slash"
        default: return "network"
        }
    }

    private static var hardwareIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            identifier.append(Character(UnicodeScalar(UInt8(value))))
        }
    }
}
