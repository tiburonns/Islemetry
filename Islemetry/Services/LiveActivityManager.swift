import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published private(set) var activeActivityID: String?
    @Published private(set) var lastError: String?

    func start(with metrics: [DeviceMetric], profileName: String = "Overview") async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            lastError = "Live Activities are disabled for Islemetry."
            return
        }

        guard Activity<DeviceActivityAttributes>.activities.isEmpty else {
            await update(with: metrics)
            return
        }

        let state = makeContentState(from: metrics)
        let attributes = DeviceActivityAttributes(sessionID: UUID(), profileName: profileName)
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(5 * 60))

        do {
            let activity = try Activity<DeviceActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            activeActivityID = activity.id
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func update(with metrics: [DeviceMetric]) async {
        let content = ActivityContent(
            state: makeContentState(from: metrics),
            staleDate: Date().addingTimeInterval(5 * 60)
        )

        for activity in Activity<DeviceActivityAttributes>.activities {
            await activity.update(content)
        }

        activeActivityID = Activity<DeviceActivityAttributes>.activities.first?.id
    }

    func stop() async {
        for activity in Activity<DeviceActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        activeActivityID = nil
    }

    func syncState() {
        activeActivityID = Activity<DeviceActivityAttributes>.activities.first?.id
    }

    private func makeContentState(from metrics: [DeviceMetric]) -> DeviceActivityAttributes.ContentState {
        let preferredOrder: [DeviceMetric.Kind] = [.battery, .thermal, .network, .storage, .memory, .lowPower, .refreshRate, .cpuCores]
        let ordered = preferredOrder.compactMap { kind in metrics.first(where: { $0.kind == kind }) }
        let leading = ordered.first ?? fallbackMetric(title: "Islemetry", value: "Active", symbol: "waveform.path.ecg")
        let trailing = ordered.dropFirst().first ?? fallbackMetric(title: "Status", value: "Ready", symbol: "checkmark.circle.fill")

        let secondary = ordered.dropFirst(2).prefix(6).map {
            DeviceActivityAttributes.LiveMetric(
                key: $0.kind.rawValue,
                title: $0.title,
                value: $0.value,
                symbol: $0.symbol
            )
        }

        return DeviceActivityAttributes.ContentState(
            leadingTitle: leading.title,
            leadingValue: leading.value,
            leadingSymbol: leading.symbol,
            trailingTitle: trailing.title,
            trailingValue: trailing.value,
            trailingSymbol: trailing.symbol,
            secondary: Array(secondary),
            updatedAt: .now
        )
    }

    private func fallbackMetric(title: String, value: String, symbol: String) -> DeviceMetric {
        DeviceMetric(kind: .system, title: title, value: value, symbol: symbol)
    }
}
