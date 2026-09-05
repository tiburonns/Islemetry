import Foundation
import Network
import UIKit

@MainActor
final class DeviceTelemetryStore: ObservableObject {
    @Published private(set) var metrics: [DeviceMetric] = []
    @Published private(set) var lastUpdated: Date = .distantPast

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

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.tiburonns.islemetry.network")

    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        startNetworkMonitor()
        refresh()
    }

    deinit {
        pathMonitor.cancel()
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
            DeviceMetric(kind: .timeZone, title: language.text("Time Zone", "Zona horaria"), value: TimeZone.current.identifier, symbol: "clock", updatedAt: now)
        ]

        lastUpdated = now
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
