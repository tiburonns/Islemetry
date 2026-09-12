import BackgroundTasks
import Foundation

final class BackgroundRefreshCoordinator {
    static let shared = BackgroundRefreshCoordinator()
    static let taskIdentifier = "com.tiburonns.islemetry.refresh"

    static let lastScheduledKey = "background.lastScheduled"
    static let lastLaunchedKey = "background.lastLaunched"
    static let lastCompletedKey = "background.lastCompleted"
    static let lastResultKey = "background.lastResult"
    static let lastErrorKey = "background.lastError"

    private static let earliestRefreshInterval: TimeInterval = 15 * 60
    private var isRegistered = false

    private init() {}

    @discardableResult
    func register() -> Bool {
        guard !isRegistered else { return true }

        let registered = BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self,
                  let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }

            self.handle(refreshTask)
        }

        isRegistered = registered

        if !registered {
            UserDefaults.standard.set(
                "BGTaskScheduler registration returned false",
                forKey: Self.lastErrorKey
            )
        }

        return registered
    }

    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(
            timeIntervalSinceNow: Self.earliestRefreshInterval
        )

        BGTaskScheduler.shared.cancel(
            taskRequestWithIdentifier: Self.taskIdentifier
        )

        do {
            try BGTaskScheduler.shared.submit(request)
            UserDefaults.standard.set(
                Date().timeIntervalSince1970,
                forKey: Self.lastScheduledKey
            )
            UserDefaults.standard.removeObject(forKey: Self.lastErrorKey)
        } catch {
            UserDefaults.standard.set(
                error.localizedDescription,
                forKey: Self.lastErrorKey
            )

#if DEBUG
            print("Islemetry background refresh scheduling failed: \(error)")
#endif
        }
    }

    private func handle(_ task: BGAppRefreshTask) {
        UserDefaults.standard.set(
            Date().timeIntervalSince1970,
            forKey: Self.lastLaunchedKey
        )
        UserDefaults.standard.set(
            "running",
            forKey: Self.lastResultKey
        )

        schedule()

        let work = Task { @MainActor in
            let telemetry = DeviceTelemetryStore()
            await telemetry.refreshAllForBackground()
        }

        task.expirationHandler = {
            UserDefaults.standard.set(
                "expired",
                forKey: Self.lastResultKey
            )
            work.cancel()
        }

        Task {
            await work.value

            let success = !work.isCancelled
            UserDefaults.standard.set(
                Date().timeIntervalSince1970,
                forKey: Self.lastCompletedKey
            )
            UserDefaults.standard.set(
                success ? "success" : "cancelled",
                forKey: Self.lastResultKey
            )

            task.setTaskCompleted(success: success)
        }
    }
}
