import Foundation

@main
struct BackgroundRefreshOutcomeTests {
    static func main() throws {
        try expect(
            BackgroundRefreshOutcome(
                liveActivityUpdated: true,
                weather: .refreshed
            ).persistenceToken == "success",
            "A complete refresh should persist success"
        )

        try expect(
            BackgroundRefreshOutcome(
                liveActivityUpdated: true,
                weather: .failed
            ).persistenceToken == "partialWeatherFailure",
            "Weather failure must remain visible when Live Activity updated"
        )

        try expect(
            BackgroundRefreshOutcome(
                liveActivityUpdated: false,
                weather: .refreshed
            ).persistenceToken == "weatherOnly",
            "A weather-only refresh should not be reported as total failure"
        )

        try expect(
            BackgroundRefreshOutcome(
                liveActivityUpdated: false,
                weather: .failed
            ).persistenceToken == "weatherFailed",
            "A failed weather refresh without Live Activity should be explicit"
        )

        try expect(
            BackgroundRefreshOutcome(
                liveActivityUpdated: false,
                weather: .notAttempted
            ).persistenceToken == "noActivity",
            "No activity and no weather attempt should preserve legacy noActivity semantics"
        )

        try expect(
            BackgroundRefreshOutcome.cancelled.persistenceToken == "cancelled",
            "Cancellation should always win over partial results"
        )

        print("PASS: Islemetry background refresh outcome policy")
    }

    private static func expect(
        _ condition: @autoclosure () -> Bool,
        _ message: String
    ) throws {
        guard condition() else {
            throw TestFailure(message)
        }
    }
}

struct TestFailure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
