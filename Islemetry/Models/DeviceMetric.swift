import Foundation

struct DeviceMetric: Identifiable, Hashable, Codable {
    enum Kind: String, Codable, CaseIterable {
        case battery
        case charging
        case lowPower
        case thermal
        case memory
        case storage
        case cpuCores
        case refreshRate
        case network
        case device
        case system
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
