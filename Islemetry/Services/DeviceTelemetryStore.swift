import Foundation
import Network
import UIKit

@MainActor
final class DeviceTelemetryStore: ObservableObject {
    @Published private(set) var metrics: [DeviceMetric] = []
    @Published private(set) var lastUpdated: Date = .distantPast
    @Published private(set) var networkDescription = "Checking…"

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
        let batteryLevel = device.batteryLevel >= 0 ? Int((device.batteryLevel * 100).rounded()) : nil
        let memory = ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .memory)
        let storage = storageDescription()
        let refreshRate = UIScreen.main.maximumFramesPerSecond

        metrics = [
            DeviceMetric(kind: .battery, title: "Battery", value: batteryLevel.map { "\($0)%" } ?? "Unknown", symbol: batterySymbol(level: batteryLevel), updatedAt: now),
            DeviceMetric(kind: .charging, title: "Power", value: chargingDescription(device.batteryState), symbol: "bolt.fill", updatedAt: now),
            DeviceMetric(kind: .lowPower, title: "Low Power", value: processInfo.isLowPowerModeEnabled ? "On" : "Off", symbol: "leaf.fill", updatedAt: now),
            DeviceMetric(kind: .thermal, title: "Thermal", value: thermalDescription(processInfo.thermalState), symbol: "thermometer.medium", updatedAt: now),
            DeviceMetric(kind: .memory, title: "Memory", value: memory, symbol: "memorychip", updatedAt: now),
            DeviceMetric(kind: .storage, title: "Storage", value: storage, symbol: "internaldrive", updatedAt: now),
            DeviceMetric(kind: .cpuCores, title: "CPU Cores", value: "\(processInfo.processorCount)", symbol: "cpu", updatedAt: now),
            DeviceMetric(kind: .refreshRate, title: "Display", value: "\(refreshRate) Hz max", symbol: "rectangle.inset.filled", updatedAt: now),
            DeviceMetric(kind: .network, title: "Network", value: networkDescription, symbol: networkSymbol(), updatedAt: now),
            DeviceMetric(kind: .device, title: "Device", value: Self.hardwareIdentifier, symbol: "iphone", updatedAt: now),
            DeviceMetric(kind: .system, title: "iOS", value: device.systemVersion, symbol: "gear", updatedAt: now)
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
                self.refresh()
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    private func storageDescription() -> String {
        do {
            let values = try URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            guard let total = values.volumeTotalCapacity,
                  let available = values.volumeAvailableCapacity else {
                return "Unknown"
            }
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            return "\(formatter.string(fromByteCount: Int64(available))) free / \(formatter.string(fromByteCount: Int64(total)))"
        } catch {
            return "Unavailable"
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
