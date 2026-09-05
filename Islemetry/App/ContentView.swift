import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var telemetry: DeviceTelemetryStore
    @StateObject private var liveActivity = LiveActivityManager()

    @AppStorage(AppLanguage.storageKey)
    private var appLanguageRaw = AppLanguage.english.rawValue

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

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .english
    }

    private var leadingKind: DeviceMetric.Kind {
        DeviceMetric.Kind(rawValue: leadingMetricRaw) ?? .battery
    }

    private var trailingKind: DeviceMetric.Kind {
        DeviceMetric.Kind(rawValue: trailingMetricRaw) ?? .thermal
    }

    private var expandedKinds: [DeviceMetric.Kind] {
        let rawValues = [expanded1, expanded2, expanded3, expanded4, expanded5, expanded6]
        var seen = Set<DeviceMetric.Kind>()

        return rawValues.compactMap { rawValue in
            guard rawValue != IslandConfiguration.noneValue,
                  let kind = DeviceMetric.Kind(rawValue: rawValue),
                  seen.insert(kind).inserted else {
                return nil
            }
            return kind
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusCard
                    controls
                    languageCard
                    islandPreviewCard
                    islandConfigurationCard
                    metricsGrid
                }
                .padding()
            }
            .navigationTitle("Islemetry")
            .task {
                liveActivity.syncState()
            }
            .onChange(of: appLanguageRaw) { _, _ in
                telemetry.refresh()
                if liveActivity.activeActivityID != nil {
                    refreshLiveActivity(startIfNeeded: false)
                }
            }
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: liveActivity.activeActivityID == nil ? "circle" : "circle.fill")
                Text(
                    liveActivity.activeActivityID == nil
                    ? language.text("Live Monitor Stopped", "Monitor en vivo detenido")
                    : language.text("Live Monitor Running", "Monitor en vivo activo")
                )
                .font(.headline)
                Spacer()
            }

            HStack(spacing: 4) {
                Text(language.text("Last snapshot:", "Última captura:"))
                Text(telemetry.lastUpdated, style: .relative)
            }
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
                    liveActivity.activeActivityID == nil
                        ? language.text("Start", "Iniciar")
                        : language.text("Refresh", "Actualizar"),
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
                .accessibilityLabel(language.text("Stop", "Detener"))
            }
        }
    }

    private var languageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(language.text("Language", "Idioma"), systemImage: "globe")
                .font(.headline)

            Picker(language.text("Language", "Idioma"), selection: $appLanguageRaw) {
                ForEach(AppLanguage.allCases) { option in
                    Text(option.displayName)
                        .tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Text(
                language.text(
                    "The selected language is used by Islemetry and is applied to the Live Activity when it updates.",
                    "El idioma seleccionado se usa en Islemetry y se aplica a la Live Activity cuando se actualiza."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var islandPreviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    language.text("Dynamic Island Preview", "Vista previa de Isla Dinámica"),
                    systemImage: "capsule.fill"
                )
                .font(.headline)

                Spacer()

                if liveActivity.activeActivityID != nil {
                    Text(language.text("LIVE", "ACTIVA"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.green)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(language.text("Compact", "Compacta"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    compactPreviewMetric(leadingKind)
                    Spacer(minLength: 8)
                    compactPreviewMetric(trailingKind)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(.white)
                .background(.black, in: Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(language.text("Expanded", "Expandida"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        expandedPreviewMetric(leadingKind)
                        Spacer(minLength: 12)
                        expandedPreviewMetric(trailingKind)
                    }

                    if expandedKinds.isEmpty {
                        Text(language.text("No expanded metrics selected", "No hay métricas expandidas seleccionadas"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(expandedKinds) { kind in
                                expandedPreviewMetric(kind)
                            }
                        }
                    }
                }
                .padding(14)
                .foregroundStyle(.white)
                .background(.black, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            Text(
                language.text(
                    "This preview uses the same saved selections that are sent to ActivityKit.",
                    "Esta vista usa las mismas selecciones guardadas que se envían a ActivityKit."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var islandConfigurationCard: some View {
        NavigationLink {
            IslandConfigurationView {
                refreshLiveActivity(startIfNeeded: false)
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(language.text("Configure Dynamic Island", "Configurar Isla Dinámica"), systemImage: "slider.horizontal.3")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    islandSlot(
                        title: language.text("Leading", "Izquierda"),
                        kind: leadingKind
                    )
                    islandSlot(
                        title: language.text("Trailing", "Derecha"),
                        kind: trailingKind
                    )
                }

                Text(
                    language.text(
                        "Choose the two compact metrics and up to six expanded metrics.",
                        "Elige las dos métricas compactas y hasta seis métricas expandidas."
                    )
                )
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
            Text(kind.selectionTitle(language: language))
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
                Text(language.text("Available Metrics", "Métricas disponibles"))
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

    private func compactPreviewMetric(_ kind: DeviceMetric.Kind) -> some View {
        let metric = metric(for: kind)

        return HStack(spacing: 5) {
            Image(systemName: metric.symbol)
            Text(metric.value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func expandedPreviewMetric(_ kind: DeviceMetric.Kind) -> some View {
        let metric = metric(for: kind)

        return HStack(spacing: 7) {
            Image(systemName: metric.symbol)
                .font(.caption)
            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Text(metric.value)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metric(for kind: DeviceMetric.Kind) -> DeviceMetric {
        telemetry.metrics.first(where: { $0.kind == kind })
            ?? DeviceMetric(
                kind: kind,
                title: kind.selectionTitle(language: language),
                value: "—",
                symbol: "circle"
            )
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

    @AppStorage(AppLanguage.storageKey)
    private var appLanguageRaw = AppLanguage.english.rawValue

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

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .english
    }

    var body: some View {
        Form {
            Section {
                metricPicker(language.text("Leading", "Izquierda"), selection: $leadingMetricRaw)
                metricPicker(language.text("Trailing", "Derecha"), selection: $trailingMetricRaw)
            } header: {
                Text(language.text("Compact Dynamic Island", "Isla Dinámica compacta"))
            } footer: {
                Text(
                    language.text(
                        "These are the two values visible while the Dynamic Island is compact.",
                        "Estos son los dos valores visibles mientras la Isla Dinámica está compacta."
                    )
                )
            }

            Section {
                expandedPicker(language.text("Slot 1", "Posición 1"), selection: $expanded1)
                expandedPicker(language.text("Slot 2", "Posición 2"), selection: $expanded2)
                expandedPicker(language.text("Slot 3", "Posición 3"), selection: $expanded3)
                expandedPicker(language.text("Slot 4", "Posición 4"), selection: $expanded4)
                expandedPicker(language.text("Slot 5", "Posición 5"), selection: $expanded5)
                expandedPicker(language.text("Slot 6", "Posición 6"), selection: $expanded6)
            } header: {
                Text(language.text("Expanded Dynamic Island", "Isla Dinámica expandida"))
            } footer: {
                Text(
                    language.text(
                        "Choose None for any expanded slot you do not want to display.",
                        "Elige Ninguna en cualquier posición expandida que no quieras mostrar."
                    )
                )
            }

            Section {
                Button {
                    onApply()
                } label: {
                    Label(
                        language.text("Apply to Live Activity", "Aplicar a Live Activity"),
                        systemImage: "checkmark.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } footer: {
                Text(
                    language.text(
                        "Selections are saved automatically. Apply updates an activity that is already running; otherwise they are used the next time you press Start.",
                        "Las selecciones se guardan automáticamente. Aplicar actualiza una actividad que ya está activa; de lo contrario se usarán la próxima vez que pulses Iniciar."
                    )
                )
            }
        }
        .navigationTitle(language.text("Dynamic Island", "Isla Dinámica"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func metricPicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            ForEach(DeviceMetric.Kind.allCases) { kind in
                Text(kind.selectionTitle(language: language))
                    .tag(kind.rawValue)
            }
        }
    }

    private func expandedPicker(_ title: String, selection: Binding<String>) -> some View {
        Picker(title, selection: selection) {
            Text(language.text("None", "Ninguna"))
                .tag(IslandConfiguration.noneValue)

            ForEach(DeviceMetric.Kind.allCases) { kind in
                Text(kind.selectionTitle(language: language))
                    .tag(kind.rawValue)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DeviceTelemetryStore())
}
