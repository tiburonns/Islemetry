import ActivityKit
import SwiftUI
import WidgetKit

struct IslemetryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeviceActivityAttributes.self) { context in
            let textColor = Color(islemetryHex: context.state.textColorHex)

            lockScreenView(
                context.state,
                profileName: context.state.languageCode == "es" ? "Personalizado" : "Custom",
                textColor: textColor
            )
            .activityBackgroundTint(.black.opacity(0.88))
            .activitySystemActionForegroundColor(textColor)
        } dynamicIsland: { context in
            let textColor = Color(islemetryHex: context.state.textColorHex)

            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    expandedMetric(
                        title: context.state.leadingTitle,
                        value: context.state.leadingValue,
                        symbol: context.state.leadingSymbol,
                        textColor: textColor
                    )
                }

                DynamicIslandExpandedRegion(.trailing) {
                    expandedMetric(
                        title: context.state.trailingTitle,
                        value: context.state.trailingValue,
                        symbol: context.state.trailingSymbol,
                        textColor: textColor
                    )
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.languageCode == "es" ? "Personalizado" : "Custom")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(textColor.opacity(0.68))
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        if !context.state.secondary.isEmpty {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(context.state.secondary) { metric in
                                    HStack(spacing: 6) {
                                        Image(systemName: metric.symbol)
                                            .font(.caption)
                                            .foregroundStyle(textColor)

                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(metric.title)
                                                .font(.caption2)
                                                .foregroundStyle(textColor.opacity(0.68))

                                            Text(metric.value)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(textColor)
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
                        .foregroundStyle(textColor.opacity(0.68))
                    }
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: context.state.leadingSymbol)
                    Text(context.state.leadingValue)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(textColor)
            } compactTrailing: {
                HStack(spacing: 4) {
                    Image(systemName: context.state.trailingSymbol)
                    Text(context.state.trailingValue)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(textColor)
            } minimal: {
                Image(systemName: context.state.leadingSymbol)
                    .foregroundStyle(textColor)
            }
            .widgetURL(URL(string: "islemetry://live"))
        }
    }

    private func lockScreenView(
        _ state: DeviceActivityAttributes.ContentState,
        profileName: String,
        textColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Islemetry", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundStyle(textColor)

                Spacer()

                Text(profileName)
                    .font(.caption)
                    .foregroundStyle(textColor.opacity(0.68))
            }

            HStack(spacing: 16) {
                expandedMetric(
                    title: state.leadingTitle,
                    value: state.leadingValue,
                    symbol: state.leadingSymbol,
                    textColor: textColor
                )

                Spacer()

                expandedMetric(
                    title: state.trailingTitle,
                    value: state.trailingValue,
                    symbol: state.trailingSymbol,
                    textColor: textColor
                )
            }

            if !state.secondary.isEmpty {
                HStack(spacing: 12) {
                    ForEach(state.secondary.prefix(4)) { metric in
                        VStack(alignment: .leading, spacing: 2) {
                            Label(metric.title, systemImage: metric.symbol)
                                .font(.caption2)
                                .foregroundStyle(textColor.opacity(0.68))

                            Text(metric.value)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(textColor)
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
            .foregroundStyle(textColor.opacity(0.68))
        }
        .padding(.horizontal, 4)
    }

    private func expandedMetric(
        title: String,
        value: String,
        symbol: String,
        textColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: symbol)
                .font(.caption2)
                .foregroundStyle(textColor.opacity(0.68))

            Text(value)
                .font(.headline)
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

private extension Color {
    init(islemetryHex hex: String?) {
        let fallback = "#FFFFFF"
        let source = (hex?.isEmpty == false ? hex! : fallback)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var value: UInt64 = 0
        guard Scanner(string: source).scanHexInt64(&value) else {
            self = .white
            return
        }

        switch source.count {
        case 6:
            let red = Double((value >> 16) & 0xFF) / 255
            let green = Double((value >> 8) & 0xFF) / 255
            let blue = Double(value & 0xFF) / 255
            self = Color(red: red, green: green, blue: blue)

        case 8:
            let red = Double((value >> 24) & 0xFF) / 255
            let green = Double((value >> 16) & 0xFF) / 255
            let blue = Double((value >> 8) & 0xFF) / 255
            let alpha = Double(value & 0xFF) / 255
            self = Color(red: red, green: green, blue: blue, opacity: alpha)

        default:
            self = .white
        }
    }
}
