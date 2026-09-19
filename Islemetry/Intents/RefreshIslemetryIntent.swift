import AppIntents
import Foundation

struct RefreshIslemetryIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh Islemetry"
    static let description = IntentDescription(
        "Refresh all Islemetry device telemetry and update the existing Live Activity."
    )

    static var openAppWhenRun: Bool { false }

    @available(iOS 26.0, *)
    static var supportedModes: IntentModes { .background }

    static let lastStartedKey = "shortcuts.refresh.lastStarted"
    static let lastCompletedKey = "shortcuts.refresh.lastCompleted"
    static let lastResultKey = "shortcuts.refresh.lastResult"
    static let lastErrorKey = "shortcuts.refresh.lastError"

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults.standard

        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastStartedKey)
        defaults.set("running", forKey: Self.lastResultKey)
        defaults.removeObject(forKey: Self.lastErrorKey)

        guard !Task.isCancelled else {
            defaults.set("cancelled", forKey: Self.lastResultKey)
            return .result(dialog: "Islemetry refresh was cancelled.")
        }

        let telemetry = DeviceTelemetryStore()
        let outcome = await telemetry.refreshAllForBackground()

        guard !Task.isCancelled, !outcome.cancelled else {
            defaults.set("cancelled", forKey: Self.lastResultKey)
            return .result(dialog: "Islemetry refresh was cancelled.")
        }

        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastCompletedKey)
        defaults.set(
            outcome.persistenceToken,
            forKey: Self.lastResultKey
        )

        switch outcome.persistenceToken {
        case "success":
            return .result(dialog: "Islemetry telemetry refreshed.")
        case "partialWeatherFailure":
            return .result(dialog: "The Live Activity was updated, but weather could not be refreshed.")
        case "weatherOnly":
            return .result(dialog: "Weather and telemetry were refreshed, but no active Islemetry Live Activity was available to update.")
        case "weatherFailed":
            return .result(dialog: "Telemetry refreshed, but weather failed and no active Islemetry Live Activity was available.")
        default:
            return .result(dialog: "Telemetry refreshed, but no active Islemetry Live Activity was available to update.")
        }
    }
}

struct IslemetryShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RefreshIslemetryIntent(),
            phrases: [
                "Refresh \(.applicationName)",
                "Update \(.applicationName)",
                "Actualizar \(.applicationName)"
            ],
            shortTitle: "Refresh Islemetry",
            systemImageName: "arrow.triangle.2.circlepath"
        )
    }

}
