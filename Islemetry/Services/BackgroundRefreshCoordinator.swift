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

    static let hasPendingRequestKey = "background.hasPendingRequest"
    static let nextEligibleKey = "background.nextEligible"

    static let lastManualStartedKey = "background.lastManualStarted"
    static let lastManualCompletedKey = "background.lastManualCompleted"
    static let lastManualResultKey = "background.lastManualResult"

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

    @discardableResult
    func schedule() -> Bool {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        let nextEligible = Date(
            timeIntervalSinceNow: Self.earliestRefreshInterval
        )
        request.earliestBeginDate = nextEligible

        BGTaskScheduler.shared.cancel(
            taskRequestWithIdentifier: Self.taskIdentifier
        )

        do {
            try BGTaskScheduler.shared.submit(request)

            let defaults = UserDefaults.standard
            defaults.set(
                Date().timeIntervalSince1970,
                forKey: Self.lastScheduledKey
            )
            defaults.set(
                nextEligible.timeIntervalSince1970,
                forKey: Self.nextEligibleKey
            )
            defaults.removeObject(forKey: Self.lastErrorKey)

            Task {
                await refreshPendingStatus()
            }

            return true
        } catch {
            let defaults = UserDefaults.standard
            defaults.set(
                error.localizedDescription,
                forKey: Self.lastErrorKey
            )
            defaults.set(false, forKey: Self.hasPendingRequestKey)

#if DEBUG
            print("Islemetry background refresh scheduling failed: \(error)")
#endif
            return false
        }
    }

    func refreshPendingStatus() async {
        let requests = await BGTaskScheduler.shared.pendingTaskRequests()
        let matchingRequest = requests.first {
            $0.identifier == Self.taskIdentifier
        }

        let defaults = UserDefaults.standard
        defaults.set(
            matchingRequest != nil,
            forKey: Self.hasPendingRequestKey
        )

        if let date = matchingRequest?.earliestBeginDate {
            defaults.set(
                date.timeIntervalSince1970,
                forKey: Self.nextEligibleKey
            )
        } else if matchingRequest == nil {
            defaults.removeObject(forKey: Self.nextEligibleKey)
        }
    }

    @MainActor
    func runManualRefresh(using telemetry: DeviceTelemetryStore) async {
        let defaults = UserDefaults.standard
        defaults.set(
            Date().timeIntervalSince1970,
            forKey: Self.lastManualStartedKey
        )
        defaults.set(
            "running",
            forKey: Self.lastManualResultKey
        )

        guard !Task.isCancelled else {
            defaults.set(
                "cancelled",
                forKey: Self.lastManualResultKey
            )
            return
        }

        await telemetry.refreshAllForBackground()

        guard !Task.isCancelled else {
            defaults.set(
                "cancelled",
                forKey: Self.lastManualResultKey
            )
            return
        }

        defaults.set(
            Date().timeIntervalSince1970,
            forKey: Self.lastManualCompletedKey
        )
        defaults.set(
            "success",
            forKey: Self.lastManualResultKey
        )
    }

    private func handle(_ task: BGAppRefreshTask) {
        let defaults = UserDefaults.standard
        defaults.set(
            Date().timeIntervalSince1970,
            forKey: Self.lastLaunchedKey
        )
        defaults.set(
            "running",
            forKey: Self.lastResultKey
        )
        defaults.set(false, forKey: Self.hasPendingRequestKey)

        schedule()

        let work = Task { @MainActor in
            let telemetry = DeviceTelemetryStore()
            await telemetry.refreshAllForBackground()
        }

        task.expirationHandler = {
            defaults.set(
                "expired",
                forKey: Self.lastResultKey
            )
            work.cancel()
        }

        Task {
            await work.value

            let success = !work.isCancelled
            defaults.set(
                Date().timeIntervalSince1970,
                forKey: Self.lastCompletedKey
            )
            defaults.set(
                success ? "success" : "cancelled",
                forKey: Self.lastResultKey
            )

            task.setTaskCompleted(success: success)
        }
    }
}
