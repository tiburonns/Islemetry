import Foundation
import Network
import UIKit

@MainActor
final class DeviceTelemetryStore: ObservableObject {
    @Published private(set) var metrics: [DeviceMetric] = []
    @Published private(set) var lastUpdated: Date = .distantPast
    @Published private(set) var networkDescription = "Checking…"

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
        let processInfo = ProcessInfo.processInfo
        let device = UIDevice.current
        let screen = UIScreen.main

        let batteryLevel = device.batteryLevel >= 0 ? Int((device.batteryLevel * 100).rounded()) : nil
        let memory = ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .memory)
        let storage = storageValues()
        let refreshRate = screen.maximumFramesPerSecond
        let brightness = Int((screen.brightness * 100).rounded())
        let resolution = "\(Int(screen.nativeBounds.width))×\(Int(screen.nativeBounds.height)) px"
        let displayScale = String(format: "%.2f×", screen.nativeScale)

        metrics = [
            DeviceMetric(kind: .battery, title: "Battery", value: batteryLevel.map { "\($0)%" } ?? "Unknown", symbol: batterySymbol(level: batteryLevel), updatedAt: now),
            DeviceMetric(kind: .charging, title: "Power", value: chargingDescription(device.batteryState), symbol: "bolt.fill", updatedAt: now),
            DeviceMetric(kind: .lowPower, title: "Low Power", value: processInfo.isLowPowerModeEnabled ? "On" : "Off", symbol: "leaf.fill", updatedAt: now),
            DeviceMetric(kind: .thermal, title: "Thermal", value: thermalDescription(processInfo.thermalState), symbol: "thermometer.medium", updatedAt: now),
            DeviceMetric(kind: .memory, title: "Memory Total", value: memory, symbol: "memorychip", updatedAt: now),
            DeviceMetric(kind: .storage, title: "Storage", value: storage.summary, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .storageFree, title: "Storage Free", value: storage.free, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .storageUsed, title: "Storage Used", value: storage.used, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .storageTotal, title: "Storage Total", value: storage.total, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .cpuCores, title: "CPU Cores", value: "\(processInfo.processorCount)", symbol: "cpu", updatedAt: now),
            DeviceMetric(kind: .activeCpuCores, title: "Active Cores", value: "\(processInfo.activeProcessorCount)", symbol: "cpu", updatedAt: now),
            DeviceMetric(kind: .refreshRate, title: "Refresh Rate", value: "\(refreshRate) Hz max", symbol: "rectangle.inset.filled", updatedAt: now),
            DeviceMetric(kind: .promotion, title: "ProMotion", value: refreshRate > 60 ? "Up to \(refreshRate) Hz" : "Not active", symbol: "speedometer", updatedAt: now),
            DeviceMetric(kind: .displayResolution, title: "Resolution", value: resolution, symbol: "rectangle", updatedAt: now),
            DeviceMetric(kind: .displayScale, title: "Display Scale", value: displayScale, symbol: "arrow.up.left.and.arrow.down.right", updatedAt: now),
            DeviceMetric(kind: .brightness, title: "Brightness", value: "\(brightness)%", symbol: "sun.max.fill", updatedAt: now),
            DeviceMetric(kind: .network, title: "Network", value: networkDescription, symbol: networkSymbol(), updatedAt: now),
            DeviceMetric(kind: .lowDataMode, title: "Low Data", value: networkConstrained ? "On" : "Off", symbol: "tortoise.fill", updatedAt: now),
            DeviceMetric(kind: .networkExpensive, title: "Network Cost", value: networkExpensive ? "Expensive" : "Normal", symbol: "antenna.radiowaves.left.and.right", updatedAt: now),
            DeviceMetric(kind: .ipv4, title: "IPv4", value: supportDescription(networkSupportsIPv4), symbol: "4.circle.fill", updatedAt: now),
            DeviceMetric(kind: .ipv6, title: "IPv6", value: supportDescription(networkSupportsIPv6), symbol: "6.circle.fill", updatedAt: now),
            DeviceMetric(kind: .dns, title: "DNS", value: supportDescription(networkSupportsDNS), symbol: "network", updatedAt: now),
            DeviceMetric(kind: .device, title: "Hardware", value: Self.hardwareIdentifier, symbol: "iphone", updatedAt: now),
            DeviceMetric(kind: .deviceModel, title: "Device Model", value: device.localizedModel, symbol: "iphone", updatedAt: now),
            DeviceMetric(kind: .system, title: "System", value: "\(device.systemName) \(device.systemVersion)", symbol: "gear", updatedAt: now),
            DeviceMetric(kind: .locale, title: "Locale", value: Locale.current.identifier, symbol: "globe", updatedAt: now),
            DeviceMetric(kind: .timeZone, title: "Time Zone", value: TimeZone.current.identifier, symbol: "clock", updatedAt: now)
        ]

        lastUpdated = now
    }

    private func startNetworkMonitor() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let description: String
            if path.status != .satisfied {
                description = "Offline"
            } else if path.usesInterfaceType(.wifi) {
                description = path.isConstrained ? "Wi-Fi · Low Data" : "Wi-Fi"
            } else if path.usesInterfaceType(.cellular) {
                description = path.isConstrained ? "Cellular · Low Data" : "Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                description = "Ethernet"
            } else {
                description = "Connected"
            }

            Task { @MainActor [weak self] in
                guard let self else { return }
                self.networkDescription = description
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

    private func storageValues() -> (summary: String, free: String, used: String, total: String) {
        do {
            let values = try URL(fileURLWithPath: NSHomeDirectory()).resourceValues(
                forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]
            )

            guard let total = values.volumeTotalCapacity,
                  let available = values.volumeAvailableCapacity else {
                return ("Unknown", "Unknown", "Unknown", "Unknown")
            }

            let used = max(total - available, 0)
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file

            let freeString = formatter.string(fromByteCount: Int64(available))
            let usedString = formatter.string(fromByteCount: Int64(used))
            let totalString = formatter.string(fromByteCount: Int64(total))

            return (
                "\(freeString) free / \(totalString)",
                freeString,
                usedString,
                totalString
            )
        } catch {
            return ("Unavailable", "Unavailable", "Unavailable", "Unavailable")
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

    private func chargingDescription(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "Charging"
        case .full: return "Full"
        case .unplugged: return "On battery"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }

    private func thermalDescription(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }

    private func supportDescription(_ supported: Bool) -> String {
        supported ? "Supported" : "Unavailable"
    }

    private func networkSymbol() -> String {
        switch networkDescription {
        case let value where value.hasPrefix("Wi-Fi"): return "wifi"
        case let value where value.hasPrefix("Cellular"): return "antenna.radiowaves.left.and.right"
        case "Offline": return "wifi.slash"
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
