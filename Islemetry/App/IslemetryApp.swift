// Copyright (c) 2026 tiburonns
// SPDX-License-Identifier: MIT

import AppIntents
import SwiftUI
import UIKit

final class IslemetryAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]? = nil
    ) -> Bool {
        BackgroundRefreshCoordinator.shared.register()
        BackgroundRefreshCoordinator.shared.schedule()
        IslemetryShortcuts.updateAppShortcutParameters()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundRefreshCoordinator.shared.schedule()
    }
}

private let _buildOriginAnchor = "dGlidXJvbm5z::Islemetry::TBNS-IM-26-2D85C9"

@main
struct IslemetryApp: App {
    @UIApplicationDelegateAdaptor(IslemetryAppDelegate.self)
    private var appDelegate

    @StateObject private var telemetry = DeviceTelemetryStore()

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
