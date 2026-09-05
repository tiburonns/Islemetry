import ActivityKit
import SwiftUI
import WidgetKit

struct IslemetryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeviceActivityAttributes.self) { context in
            lockScreenView(
                context.state,
                profileName: context.state.languageCode == "es" ? "Personalizado" : "Custom"
            )
                .activityBackgroundTint(.black.opacity(0.88))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    expandedMetric(
                        title: context.state.leadingTitle,
                        value: context.state.leadingValue,
                        symbol: context.state.leadingSymbol
                    )
                }

                DynamicIslandExpandedRegion(.trailing) {
                    expandedMetric(
                        title: context.state.trailingTitle,
                        value: context.state.trailingValue,
                        symbol: context.state.trailingSymbol
                    )
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.languageCode == "es" ? "Personalizado" : "Custom")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        if !context.state.secondary.isEmpty {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(context.state.secondary) { metric in
                                    HStack(spacing: 6) {
                                        Image(systemName: metric.symbol)
                                            .font(.caption)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(metric.title)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text(metric.value)
                                                .font(.caption.weight(.semibold))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.75)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(context.state.languageCode == "es" ? "Actualizado" : "Updated")
                            Text(context.state.updatedAt, style: .relative)
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: context.state.leadingSymbol)
                    Text(context.state.leadingValue)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                }
            } compactTrailing: {
                HStack(spacing: 4) {
                    Image(systemName: context.state.trailingSymbol)
                    Text(context.state.trailingValue)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                }
            } minimal: {
                Image(systemName: context.state.leadingSymbol)
            }
            .widgetURL(URL(string: "islemetry://live"))
        }
    }

    private func lockScreenView(
        _ state: DeviceActivityAttributes.ContentState,
        profileName: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Islemetry", systemImage: "waveform.path.ecg")
                    .font(.headline)
                Spacer()
                Text(profileName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                expandedMetric(title: state.leadingTitle, value: state.leadingValue, symbol: state.leadingSymbol)
                Spacer()
                expandedMetric(title: state.trailingTitle, value: state.trailingValue, symbol: state.trailingSymbol)
            }

            if !state.secondary.isEmpty {
                HStack(spacing: 12) {
                    ForEach(state.secondary.prefix(4)) { metric in
                        VStack(alignment: .leading, spacing: 2) {
                            Label(metric.title, systemImage: metric.symbol)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(metric.value)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            HStack(spacing: 4) {
                Text(state.languageCode == "es" ? "Actualizado" : "Updated")
                Text(state.updatedAt, style: .relative)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    private func expandedMetric(title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: symbol)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
