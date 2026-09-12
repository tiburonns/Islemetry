import BackgroundTasks
import Foundation

final class BackgroundRefreshCoordinator {
    static let shared = BackgroundRefreshCoordinator()
    static let taskIdentifier = "com.tiburonns.islemetry.refresh"

    private static let earliestRefreshInterval: TimeInterval = 15 * 60
    private var isRegistered = false

    private init() {}

    func register() {
        guard !isRegistered else { return }

        isRegistered = BGTaskScheduler.shared.register(
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
        } catch {
#if DEBUG
            print("Islemetry background refresh scheduling failed: \(error)")
#endif
        }
    }

    private func handle(_ task: BGAppRefreshTask) {
        schedule()

        let work = Task { @MainActor in
            let telemetry = DeviceTelemetryStore()
            await telemetry.refreshAllForBackground()
        }

        task.expirationHandler = {
            work.cancel()
        }

        Task {
            await work.value
            task.setTaskCompleted(success: !work.isCancelled)
        }
    }
}
