import SwiftUI

@main
struct IslemetryApp: App {
    @StateObject private var telemetry = DeviceTelemetryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(telemetry)
        }
    }
}
