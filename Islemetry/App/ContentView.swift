import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var telemetry: DeviceTelemetryStore
    @StateObject private var liveActivity = LiveActivityManager()

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
                telemetry.refresh()
                Task {
                    if liveActivity.activeActivityID == nil {
                        await liveActivity.start(with: telemetry.metrics)
                    } else {
                        await liveActivity.update(with: telemetry.metrics)
                    }
                }
            } label: {
                Label(liveActivity.activeActivityID == nil ? "Start" : "Refresh", systemImage: liveActivity.activeActivityID == nil ? "play.fill" : "arrow.clockwise")
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

    private var metricsGrid: some View {
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

#Preview {
    ContentView()
        .environmentObject(DeviceTelemetryStore())
}
