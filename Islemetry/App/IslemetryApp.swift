import SwiftUI

@main
struct IslemetryApp: App {
    @StateObject private var telemetry = DeviceTelemetryStore()

    init() {
        BackgroundRefreshCoordinator.shared.register()
        BackgroundRefreshCoordinator.shared.schedule()
    }

    @AppStorage(AppAppearance.storageKey)
    private var appAppearanceRaw = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appAppearanceRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(telemetry)
                .preferredColorScheme(appearance.colorScheme)
        }
    }
}
