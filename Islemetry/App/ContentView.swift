import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var telemetry: DeviceTelemetryStore
    @StateObject private var liveActivity = LiveActivityManager()

    @AppStorage(IslandConfiguration.leadingKey)
    private var leadingMetricRaw = DeviceMetric.Kind.battery.rawValue

    @AppStorage(IslandConfiguration.trailingKey)
    private var trailingMetricRaw = DeviceMetric.Kind.thermal.rawValue

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCard
                    controls
                    islandConfigurationCard
                    metricsGrid
                }
                .padding()
            }
            .navigationTitle("Islemetry")
            .task {
                liveActivity.syncState()
            }
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: liveActivity.activeActivityID == nil ? "circle" : "circle.fill")
                Text(liveActivity.activeActivityID == nil ? "Live Monitor Stopped" : "Live Monitor Running")
                    .font(.headline)
                Spacer()
            }

            Text("Last snapshot: \(telemetry.lastUpdated, style: .relative) ago")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let error = liveActivity.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                refreshLiveActivity(startIfNeeded: true)
            } label: {
                Label(
                    liveActivity.activeActivityID == nil ? "Start" : "Refresh",
                    systemImage: liveActivity.activeActivityID == nil ? "play.fill" : "arrow.clockwise"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if liveActivity.activeActivityID != nil {
                Button(role: .destructive) {
                    Task { await liveActivity.stop() }
                } label: {
                    Image(systemName: "stop.fill")
                        .frame(width: 44)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var islandConfigurationCard: some View {
        NavigationLink {
            IslandConfigurationView {
                refreshLiveActivity(startIfNeeded: false)
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Dynamic Island", systemImage: "capsule.fill")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    islandSlot(
                        title: "Leading",
                        kind: DeviceMetric.Kind(rawValue: leadingMetricRaw) ?? .battery
                    )
                    islandSlot(
                        title: "Trailing",
                        kind: DeviceMetric.Kind(rawValue: trailingMetricRaw) ?? .thermal
                    )
                }

                Text("Choose the two compact metrics and up to six expanded metrics.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func islandSlot(title: String, kind: DeviceMetric.Kind) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(kind.selectionTitle)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var metricsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Available Metrics")
                    .font(.headline)
                Spacer()
                Text("\(telemetry.metrics.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(telemetry.metrics) { metric in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: metric.symbol)
                            Text(metric.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(metric.value)
                            .font(.headline)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private func refreshLiveActivity(startIfNeeded: Bool) {
        telemetry.refresh()
        let configuration = IslandConfiguration.current

        Task {
            if liveActivity.activeActivityID == nil {
                if startIfNeeded {
                    await liveActivity.start(
                        with: telemetry.metrics,
                        configuration: configuration
                    )
                }
            } else {
                await liveActivity.update(
                    with: telemetry.metrics,
                    configuration: configuration
                )
            }
        }
    }
}

private struct IslandConfigurationView: View {
    let onApply: () -> Void

    @AppStorage(IslandConfiguration.leadingKey)
    private var leadingMetricRaw = DeviceMetric.Kind.battery.rawValue

    @AppStorage(IslandConfiguration.trailingKey)
    private var trailingMetricRaw = DeviceMetric.Kind.thermal.rawValue

    @AppStorage("island.expandedMetric1")
    private var expanded1 = DeviceMetric.Kind.network.rawValue

    @AppStorage("island.expandedMetric2")
    private var expanded2 = DeviceMetric.Kind.storageFree.rawValue

    @AppStorage("island.expandedMetric3")
    private var expanded3 = DeviceMetric.Kind.memory.rawValue

    @AppStorage("island.expandedMetric4")
    private var expanded4 = DeviceMetric.Kind.activeCpuCores.rawValue

    @AppStorage("island.expandedMetric5")
    private var expanded5 = DeviceMetric.Kind.refreshRate.rawValue

    @AppStorage("island.expandedMetric6")
    private var expanded6 = DeviceMetric.Kind.lowPower.rawValue

    var body: some View {
        Form {
            Section("Compact Dynamic Island") {
                metricPicker("Leading", selection: $leadingMetricRaw)
                metricPicker("Trailing", selection: $trailingMetricRaw)
            } footer: {
                Text("These are the two values visible while the Dynamic Island is compact.")
            }

            Section("Expanded Dynamic Island") {
                expandedPicker("Slot 1", selection: $expanded1)
                expandedPicker("Slot 2", selection: $expanded2)
                expandedPicker("Slot 3", selection: $expanded3)
                expandedPicker("Slot 4", selection: $expanded4)
                expandedPicker("Slot 5", selection: $expanded5)
                expandedPicker("Slot 6", selection: $expanded6)
            } footer: {
                Text("Choose None for any expanded slot you do not want to display.")
            }

            Section {
                Button {
                    onApply()
                } label: {
                    Label("Apply to Live Activity", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } footer: {
                Text("Selections are saved automatically. Apply updates an activity that is already running; otherwise they are used the next time you press Start.")
            }
        }
        .navigationTitle("Dynamic Island")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func metricPicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            ForEach(DeviceMetric.Kind.allCases) { kind in
                Text(kind.selectionTitle)
                    .tag(kind.rawValue)
            }
        }
    }

    private func expandedPicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            Text("None")
                .tag(IslandConfiguration.noneValue)

            ForEach(DeviceMetric.Kind.allCases) { kind in
                Text(kind.selectionTitle)
                    .tag(kind.rawValue)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DeviceTelemetryStore())
}
