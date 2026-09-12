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
        await telemetry.refreshAllForBackground()

        guard !Task.isCancelled else {
            defaults.set("cancelled", forKey: Self.lastResultKey)
            return .result(dialog: "Islemetry refresh was cancelled.")
        }

        defaults.set(Date().timeIntervalSince1970, forKey: Self.lastCompletedKey)
        defaults.set("success", forKey: Self.lastResultKey)

        return .result(dialog: "Islemetry telemetry refreshed.")
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

    static var shortcutTileColor: ShortcutTileColor { .cyan }
}
