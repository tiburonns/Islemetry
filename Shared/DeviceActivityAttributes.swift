import ActivityKit
import Foundation

struct DeviceActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var leadingTitle: String
        var leadingValue: String
        var leadingSymbol: String
        var trailingTitle: String
        var trailingValue: String
        var trailingSymbol: String
        var secondary: [LiveMetric]
        var updatedAt: Date
        var languageCode: String
    }

    struct LiveMetric: Codable, Hashable, Identifiable {
        var id: String { key }
        let key: String
        let title: String
        let value: String
        let symbol: String
    }

    let sessionID: UUID
    let profileName: String
}
