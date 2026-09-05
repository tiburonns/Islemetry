import ActivityKit
import Foundation

struct IslandConfiguration: Equatable {
    static let noneValue = "none"

    static let leadingKey = "island.leadingMetric"
    static let trailingKey = "island.trailingMetric"
    static let expandedKeys = (1...6).map { "island.expandedMetric\($0)" }

    let leading: DeviceMetric.Kind
    let trailing: DeviceMetric.Kind
    let expanded: [DeviceMetric.Kind]

    static var current: IslandConfiguration {
        let defaults = UserDefaults.standard

        let leading = DeviceMetric.Kind(
            rawValue: defaults.string(forKey: leadingKey) ?? DeviceMetric.Kind.battery.rawValue
        ) ?? .battery

        let trailing = DeviceMetric.Kind(
            rawValue: defaults.string(forKey: trailingKey) ?? DeviceMetric.Kind.thermal.rawValue
        ) ?? .thermal

        let fallbackExpanded: [DeviceMetric.Kind] = [
            .network,
            .storageFree,
            .memory,
            .activeCpuCores,
            .refreshRate,
            .lowPower
        ]

        let expanded = expandedKeys.enumerated().compactMap { index, key -> DeviceMetric.Kind? in
            let fallback = fallbackExpanded[index].rawValue
            let rawValue = defaults.string(forKey: key) ?? fallback
            guard rawValue != noneValue else { return nil }
            return DeviceMetric.Kind(rawValue: rawValue)
        }

        return IslandConfiguration(
            leading: leading,
            trailing: trailing,
            expanded: expanded
        )
    }
}

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published private(set) var activeActivityID: String?
    @Published private(set) var lastError: String?

    func start(
        with metrics: [DeviceMetric],
        configuration: IslandConfiguration = .current,
        profileName: String? = nil
    ) async {
        let language = AppLanguage.current

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            lastError = language.text(
                "Live Activities are disabled for Islemetry.",
                "Las Live Activities están desactivadas para Islemetry."
            )
            return
        }

        guard Activity<DeviceActivityAttributes>.activities.isEmpty else {
            await update(with: metrics, configuration: configuration)
            return
        }

        let state = makeContentState(from: metrics, configuration: configuration)
        let resolvedProfileName = profileName ?? language.text("Custom", "Personalizado")
        let attributes = DeviceActivityAttributes(sessionID: UUID(), profileName: resolvedProfileName)
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

    func update(
        with metrics: [DeviceMetric],
        configuration: IslandConfiguration = .current
    ) async {
        let content = ActivityContent(
            state: makeContentState(from: metrics, configuration: configuration),
            staleDate: Date().addingTimeInterval(5 * 60)
        )

        for activity in Activity<DeviceActivityAttributes>.activities {
            await activity.update(content)
        }

        activeActivityID = Activity<DeviceActivityAttributes>.activities.first?.id
        lastError = nil
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

    private func makeContentState(
        from metrics: [DeviceMetric],
        configuration: IslandConfiguration
    ) -> DeviceActivityAttributes.ContentState {
        let language = AppLanguage.current

        let leading = metric(
            configuration.leading,
            in: metrics,
            fallback: fallbackMetric(
                title: "Islemetry",
                value: language.text("Active", "Activo"),
                symbol: "waveform.path.ecg"
            )
        )

        let trailing = metric(
            configuration.trailing,
            in: metrics,
            fallback: fallbackMetric(
                title: language.text("Status", "Estado"),
                value: language.text("Ready", "Listo"),
                symbol: "checkmark.circle.fill"
            )
        )

        var seen = Set<DeviceMetric.Kind>()
        let secondary = configuration.expanded.compactMap { kind -> DeviceActivityAttributes.LiveMetric? in
            guard seen.insert(kind).inserted,
                  let item = metrics.first(where: { $0.kind == kind }) else {
                return nil
            }

            return DeviceActivityAttributes.LiveMetric(
                key: item.kind.rawValue,
                title: item.title,
                value: item.value,
                symbol: item.symbol
            )
        }

        return DeviceActivityAttributes.ContentState(
            leadingTitle: leading.title,
            leadingValue: leading.value,
            leadingSymbol: leading.symbol,
            trailingTitle: trailing.title,
            trailingValue: trailing.value,
            trailingSymbol: trailing.symbol,
            secondary: secondary,
            updatedAt: .now,
            languageCode: language.rawValue
        )
    }

    private func metric(
        _ kind: DeviceMetric.Kind,
        in metrics: [DeviceMetric],
        fallback: DeviceMetric
    ) -> DeviceMetric {
        metrics.first(where: { $0.kind == kind }) ?? fallback
    }

    private func fallbackMetric(title: String, value: String, symbol: String) -> DeviceMetric {
        DeviceMetric(kind: .system, title: title, value: value, symbol: symbol)
    }
}
