import Foundation

struct DeviceMetric: Identifiable, Hashable, Codable {
    enum Kind: String, Codable, CaseIterable, Identifiable {
        case battery
        case charging
        case lowPower
        case thermal
        case memory
        case storage
        case storageFree
        case storageUsed
        case storageTotal
        case cpuCores
        case activeCpuCores
        case refreshRate
        case promotion
        case displayResolution
        case displayScale
        case brightness
        case network
        case lowDataMode
        case networkExpensive
        case ipv4
        case ipv6
        case dns
        case device
        case deviceModel
        case system
        case locale
        case timeZone

        var id: String { rawValue }

        var selectionTitle: String {
            switch self {
            case .battery: return "Battery"
            case .charging: return "Charging State"
            case .lowPower: return "Low Power Mode"
            case .thermal: return "Thermal State"
            case .memory: return "Memory Total"
            case .storage: return "Storage Summary"
            case .storageFree: return "Storage Free"
            case .storageUsed: return "Storage Used"
            case .storageTotal: return "Storage Total"
            case .cpuCores: return "CPU Cores"
            case .activeCpuCores: return "Active CPU Cores"
            case .refreshRate: return "Max Refresh Rate"
            case .promotion: return "ProMotion"
            case .displayResolution: return "Display Resolution"
            case .displayScale: return "Display Scale"
            case .brightness: return "Brightness"
            case .network: return "Network"
            case .lowDataMode: return "Low Data Mode"
            case .networkExpensive: return "Expensive Network"
            case .ipv4: return "IPv4"
            case .ipv6: return "IPv6"
            case .dns: return "DNS"
            case .device: return "Hardware Identifier"
            case .deviceModel: return "Device Model"
            case .system: return "System"
            case .locale: return "Locale"
            case .timeZone: return "Time Zone"
            }
        }
    }

    let id: UUID
    let kind: Kind
    let title: String
    let value: String
    let symbol: String
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        value: String,
        symbol: String,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.value = value
        self.symbol = symbol
        self.updatedAt = updatedAt
    }
}
