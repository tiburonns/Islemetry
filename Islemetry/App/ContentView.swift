import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var telemetry: DeviceTelemetryStore
    @StateObject private var liveActivity = LiveActivityManager()

    @AppStorage(AppLanguage.storageKey)
    private var appLanguageRaw = AppLanguage.system.rawValue

    @AppStorage(AppAppearance.storageKey)
    private var appAppearanceRaw = AppAppearance.system.rawValue

    @AppStorage(IslandConfiguration.leadingKey)
    private var leadingMetricRaw = DeviceMetric.Kind.battery.rawValue

    @AppStorage(IslandConfiguration.trailingKey)
    private var trailingMetricRaw = DeviceMetric.Kind.thermal.rawValue

    @AppStorage(IslandConfiguration.textColorKey)
    private var islandTextColorHex = IslandConfiguration.defaultTextColorHex

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
        AppLanguage(rawValue: appLanguageRaw) ?? .system
    }

    private var islandTextColor: Color {
        Color(islemetryHex: islandTextColorHex)
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
                    islandConfigurationCard
                    islandPreviewCard
                    locationWeatherCard
                    appearanceCard
                    languageCard
                    metricsGrid
                }
                .padding()
            }
            .navigationTitle("Islemetry")
            .task {
                liveActivity.syncState()
                telemetry.prepareLocationWeather()
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

    private var islandConfigurationCard: some View {
        NavigationLink {
            IslandConfigurationView {
                refreshLiveActivity(startIfNeeded: false)
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(
                        language.text("Configure Dynamic Island", "Configurar Isla Dinámica"),
                        systemImage: "slider.horizontal.3"
                    )
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

                HStack(spacing: 8) {
                    Circle()
                        .fill(islandTextColor)
                        .frame(width: 14, height: 14)
                        .overlay {
                            Circle().stroke(.secondary.opacity(0.35), lineWidth: 1)
                        }

                    Text(language.text("Text color", "Color del texto"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(islandTextColorHex.uppercased())
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }

                Text(
                    language.text(
                        "Choose the compact metrics, expanded metrics, and text color.",
                        "Elige las métricas compactas, las métricas expandidas y el color del texto."
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
                .foregroundStyle(islandTextColor)
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
                        Text(
                            language.text(
                                "No expanded metrics selected",
                                "No hay métricas expandidas seleccionadas"
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(islandTextColor.opacity(0.68))
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
                .foregroundStyle(islandTextColor)
                .background(.black, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            Text(
                language.text(
                    "This preview uses the same saved selections and text color sent to ActivityKit.",
                    "Esta vista usa las mismas selecciones guardadas y el color de texto enviados a ActivityKit."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var locationWeatherCard: some View {
        let temperature = metric(for: .localTemperature)
        let condition = metric(for: .weatherCondition)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    language.text("Location & Weather", "Ubicación y clima"),
                    systemImage: condition.symbol
                )
                .font(.headline)

                Spacer()

                Text(temperature.value)
                    .font(.headline.monospacedDigit())
            }

            HStack {
                Text(language.text("Location permission", "Permiso de ubicación"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(telemetry.locationAuthorizationDescription(language: language))
                    .font(.caption.weight(.semibold))
            }

            Toggle(
                language.text(
                    "Background location",
                    "Ubicación en segundo plano"
                ),
                isOn: Binding(
                    get: { telemetry.backgroundLocationEnabled },
                    set: { telemetry.setBackgroundLocationEnabled($0) }
                )
            )

            Text(
                language.text(
                    "When enabled, Islemetry can receive location updates in the background and refresh local WeatherKit telemetry when iOS gives the app execution time.",
                    "Al activarlo, Islemetry puede recibir actualizaciones de ubicación en segundo plano y refrescar la telemetría local de WeatherKit cuando iOS le concede tiempo de ejecución."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    telemetry.requestLocationAccess()
                } label: {
                    Label(
                        language.text("Allow Location", "Permitir ubicación"),
                        systemImage: "location.fill"
                    )
                }
                .buttonStyle(.bordered)

                Button {
                    telemetry.refreshLocationWeather(force: true)
                } label: {
                    Label(
                        language.text("Refresh Weather", "Actualizar clima"),
                        systemImage: "arrow.clockwise"
                    )
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(language.text("Current", "Actual"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(temperature.value)
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(language.text("Conditions", "Condiciones"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Label(condition.value, systemImage: condition.symbol)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                }
            }

            if let message = telemetry.weatherStatusMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let attributionURL = telemetry.weatherAttributionURL {
                Link(destination: attributionURL) {
                    Label(
                        language.text(
                            "Weather data: \(telemetry.weatherServiceName)",
                            "Datos meteorológicos: \(telemetry.weatherServiceName)"
                        ),
                        systemImage: "apple.logo"
                    )
                    .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                    "System follows the current iOS language. English and Español override it inside Islemetry.",
                    "Sistema sigue el idioma actual de iOS. English y Español lo reemplazan dentro de Islemetry."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(language.text("Appearance", "Apariencia"), systemImage: "circle.lefthalf.filled")
                .font(.headline)

            Picker(language.text("Appearance", "Apariencia"), selection: $appAppearanceRaw) {
                ForEach(AppAppearance.allCases) { option in
                    Text(option.displayName(language: language))
                        .tag(option.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Text(
                language.text(
                    "System follows the iPhone appearance. Light and Dark keep Islemetry in the selected mode.",
                    "Sistema sigue la apariencia del iPhone. Claro y Oscuro mantienen Islemetry en el modo elegido."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                .foregroundStyle(islandTextColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(.caption2)
                    .foregroundStyle(islandTextColor.opacity(0.68))

                Text(metric.value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(islandTextColor)
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
    private var appLanguageRaw = AppLanguage.system.rawValue

    @AppStorage(IslandConfiguration.leadingKey)
    private var leadingMetricRaw = DeviceMetric.Kind.battery.rawValue

    @AppStorage(IslandConfiguration.trailingKey)
    private var trailingMetricRaw = DeviceMetric.Kind.thermal.rawValue

    @AppStorage(IslandConfiguration.textColorKey)
    private var textColorHex = IslandConfiguration.defaultTextColorHex

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
        AppLanguage(rawValue: appLanguageRaw) ?? .system
    }

    private var textColorBinding: Binding<Color> {
        Binding(
            get: { Color(islemetryHex: textColorHex) },
            set: { textColorHex = $0.islemetryHex }
        )
    }

    var body: some View {
        Form {
            Section {
                metricPicker(
                    language.text("Leading", "Izquierda"),
                    selection: $leadingMetricRaw
                )
                metricPicker(
                    language.text("Trailing", "Derecha"),
                    selection: $trailingMetricRaw
                )
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
                ColorPicker(
                    language.text("Text color", "Color del texto"),
                    selection: textColorBinding,
                    supportsOpacity: false
                )

                HStack {
                    Text("HEX")
                    Spacer()
                    Text(textColorHex.uppercased())
                        .font(.body.monospaced())
                        .foregroundStyle(.secondary)
                }

                Button {
                    textColorHex = IslandConfiguration.defaultTextColorHex
                } label: {
                    Label(
                        language.text("Reset to white", "Restablecer a blanco"),
                        systemImage: "arrow.counterclockwise"
                    )
                }
            } header: {
                Text(language.text("Live Activity Appearance", "Apariencia de Live Activity"))
            } footer: {
                Text(
                    language.text(
                        "The selected color is used for text and metric symbols in the compact, expanded, minimal, and Lock Screen Live Activity views. White is the default.",
                        "El color seleccionado se usa para el texto y los símbolos de las métricas en las vistas compacta, expandida, mínima y de pantalla bloqueada. El blanco es el valor predeterminado."
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
                        "Selections and color are saved automatically. Apply updates an activity that is already running; otherwise they are used the next time you press Start.",
                        "Las selecciones y el color se guardan automáticamente. Aplicar actualiza una actividad que ya está activa; de lo contrario se usarán la próxima vez que pulses Iniciar."
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
