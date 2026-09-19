import Foundation

enum WeatherRefreshResult: String, Codable, Sendable {
    case notAttempted
    case refreshed
    case cached
    case inFlight
    case failed
}

struct BackgroundRefreshOutcome: Equatable, Sendable {
    var liveActivityUpdated: Bool
    var weather: WeatherRefreshResult
    var cancelled: Bool

    init(
        liveActivityUpdated: Bool,
        weather: WeatherRefreshResult = .notAttempted,
        cancelled: Bool = false
    ) {
        self.liveActivityUpdated = liveActivityUpdated
        self.weather = weather
        self.cancelled = cancelled
    }

    static let cancelled = BackgroundRefreshOutcome(
        liveActivityUpdated: false,
        weather: .notAttempted,
        cancelled: true
    )

    var persistenceToken: String {
        if cancelled {
            return "cancelled"
        }

        if liveActivityUpdated {
            return weather == .failed
                ? "partialWeatherFailure"
                : "success"
        }

        switch weather {
        case .refreshed, .cached:
            return "weatherOnly"
        case .failed:
            return "weatherFailed"
        case .notAttempted, .inFlight:
            return "noActivity"
        }
    }
}
