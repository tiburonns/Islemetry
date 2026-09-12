import AppIntents
import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var telemetry: DeviceTelemetryStore
    @StateObject private var liveActivity = LiveActivityManager()

    private static let automaticRefreshInterval: Duration = .seconds(3)

    @AppStorage(AppLanguage.storageKey)
    private var appLanguageRaw = AppLanguage.system.rawValue

    @AppStorage(AppAppearance.storageKey)
    private var appAppearanceRaw = AppAppearance.system.rawValue

    @AppStorage(BackgroundRefreshCoordinator.lastScheduledKey)
    private var backgroundLastScheduled: Double = 0

    @AppStorage(BackgroundRefreshCoordinator.lastLaunchedKey)
    private var backgroundLastLaunched: Double = 0

    @AppStorage(BackgroundRefreshCoordinator.lastCompletedKey)
    private var backgroundLastCompleted: Double = 0

    @AppStorage(BackgroundRefreshCoordinator.lastResultKey)
    private var backgroundLastResult = "never"

    @AppStorage(BackgroundRefreshCoordinator.lastErrorKey)
    private var backgroundLastError = ""

    @AppStorage(BackgroundRefreshCoordinator.hasPendingRequestKey)
    private var backgroundHasPendingRequest = false

    @AppStorage(BackgroundRefreshCoordinator.nextEligibleKey)
    private var backgroundNextEligible: Double = 0

    @AppStorage(BackgroundRefreshCoordinator.lastManualStartedKey)
    private var backgroundLastManualStarted: Double = 0

    @AppStorage(BackgroundRefreshCoordinator.lastManualCompletedKey)
    private var backgroundLastManualCompleted: Double = 0

    @AppStorage(BackgroundRefreshCoordinator.lastManualResultKey)
    private var backgroundLastManualResult = "never"

    @AppStorage(RefreshIslemetryIntent.lastStartedKey)
    private var shortcutLastStarted: Double = 0

    @AppStorage(RefreshIslemetryIntent.lastCompletedKey)
    private var shortcutLastCompleted: Double = 0

    @AppStorage(RefreshIslemetryIntent.lastResultKey)
    private var shortcutLastResult = "never"

    @AppStorage(RefreshIslemetryIntent.lastErrorKey)
    private var shortcutLastError = ""

    @State private var isManualRefreshRunning = false
    @State private var backgroundActionMessage: String?

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
                    backgroundRefreshCard
                    shortcutsAutomationCard
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
                await BackgroundRefreshCoordinator.shared.refreshPendingStatus()
            }
            .task(id: scenePhase) {
                await refreshAutomaticallyWhileActive()
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

    private var backgroundRefreshCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(
                    language.text("Background Refresh", "Actualización en segundo plano"),
                    systemImage: "arrow.triangle.2.circlepath"
                )
                .font(.headline)

                Spacer()

                Text(language.text("ALL METRICS", "TODAS"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.green)
            }

            HStack {
                Text(language.text("Foreground", "Primer plano"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(language.text("Every 3 seconds", "Cada 3 segundos"))
                    .font(.caption.weight(.semibold))
            }

            HStack {
                Text(language.text("Background", "Segundo plano"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(language.text("Scheduled by iOS", "Programado por iOS"))
                    .font(.caption.weight(.semibold))
            }

            Divider()

            diagnosticRow(
                language.text("System permission", "Permiso del sistema"),
                value: backgroundRefreshStatusText
            )

            diagnosticRow(
                language.text("Last scheduled", "Última programación"),
                value: backgroundDateText(backgroundLastScheduled)
            )

            diagnosticRow(
                language.text("Last launched", "Última ejecución"),
                value: backgroundDateText(backgroundLastLaunched)
            )

            diagnosticRow(
                language.text("Last completed", "Última finalización"),
                value: backgroundDateText(backgroundLastCompleted)
            )

            diagnosticRow(
                language.text("Last result", "Último resultado"),
                value: backgroundResultText
            )

            if !backgroundLastError.isEmpty {
                Text(backgroundLastError)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }

            diagnosticRow(
                language.text("Pending request", "Solicitud pendiente"),
                value: backgroundHasPendingRequest
                    ? language.text("Confirmed", "Confirmada")
                    : language.text("None", "Ninguna")
            )

            diagnosticRow(
                language.text("Earliest eligible", "Elegible desde"),
                value: backgroundDateText(backgroundNextEligible)
            )

            diagnosticRow(
                language.text("Last manual refresh", "Última actualización manual"),
                value: backgroundDateText(backgroundLastManualCompleted)
            )

            diagnosticRow(
                language.text("Manual result", "Resultado manual"),
                value: backgroundManualResultText
            )

            HStack(spacing: 10) {
                Button {
                    let scheduled = BackgroundRefreshCoordinator.shared.schedule()

                    backgroundActionMessage = scheduled
                        ? language.text(
                            "Request submitted. iOS decides when it runs.",
                            "Solicitud enviada. iOS decide cuándo ejecutarla."
                        )
                        : language.text(
                            "The request could not be scheduled.",
                            "No se pudo programar la solicitud."
                        )

                    Task {
                        await BackgroundRefreshCoordinator.shared.refreshPendingStatus()
                    }
                } label: {
                    Label(
                        language.text("Schedule", "Programar"),
                        systemImage: "calendar.badge.clock"
                    )
                }
                .buttonStyle(.bordered)

                Button {
                    isManualRefreshRunning = true
                    backgroundActionMessage = nil

                    Task {
                        await BackgroundRefreshCoordinator.shared.runManualRefresh(
                            using: telemetry
                        )

                        isManualRefreshRunning = false
                        backgroundActionMessage = language.text(
                            "Full snapshot sent to the existing Live Activity.",
                            "Snapshot completo enviado a la Live Activity existente."
                        )
                    }
                } label: {
                    if isManualRefreshRunning {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text(language.text("Updating…", "Actualizando…"))
                        }
                    } else {
                        Label(
                            language.text("Update now", "Actualizar ahora"),
                            systemImage: "arrow.clockwise"
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isManualRefreshRunning)
            }

            if let backgroundActionMessage {
                Text(backgroundActionMessage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(
                language.text(
                    "Schedule only confirms that iOS has a pending BGAppRefreshTask request; it does not run it immediately. Update now performs a complete foreground test of the same telemetry-to-Live-Activity path.",
                    "Programar solo confirma que iOS tiene una solicitud BGAppRefreshTask pendiente; no la ejecuta inmediatamente. Actualizar ahora realiza una prueba completa en primer plano de la misma ruta telemetría → Live Activity."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var backgroundRefreshStatusText: String {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            return language.text("Available", "Disponible")
        case .denied:
            return language.text("Disabled", "Desactivado")
        case .restricted:
            return language.text("Restricted", "Restringido")
        @unknown default:
            return language.text("Unknown", "Desconocido")
        }
    }

    private var backgroundManualResultText: String {
        switch backgroundLastManualResult {
        case "running":
            return language.text("Running", "Ejecutándose")
        case "success":
            return language.text("Success", "Correcto")
        case "cancelled":
            return language.text("Cancelled", "Cancelado")
        default:
            return language.text("Never", "Nunca")
        }
    }

    private var backgroundResultText: String {
        switch backgroundLastResult {
        case "running":
            return language.text("Running", "Ejecutándose")
        case "success":
            return language.text("Success", "Correcto")
        case "cancelled":
            return language.text("Cancelled", "Cancelado")
        case "expired":
            return language.text("Expired", "Expiró")
        default:
            return language.text("Never", "Nunca")
        }
    }

    private func backgroundDateText(_ timestamp: Double) -> String {
        guard timestamp > 0 else {
            return language.text("Never", "Nunca")
        }

        return Date(timeIntervalSince1970: timestamp)
            .formatted(date: .abbreviated, time: .standard)
    }

    private func diagnosticRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
    }

    private var shortcutsAutomationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    language.text("Shortcuts Automations", "Automatizaciones de Atajos"),
                    systemImage: "bolt.horizontal.circle.fill"
                )
                .font(.headline)

                Spacer()

                Text(language.text("EVENT-DRIVEN", "POR EVENTOS"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.green)
            }

            Text(
                language.text(
                    "Use the Refresh Islemetry action from Shortcuts automations. Charger, Wi-Fi, Bluetooth, Low Power Mode, battery level, Focus, Airplane Mode and other supported triggers can refresh the complete telemetry snapshot without opening Islemetry.",
                    "Usa la acción Actualizar Islemetry desde automatizaciones de Atajos. Cargador, Wi-Fi, Bluetooth, Modo de bajo consumo, nivel de batería, Concentración, Modo avión y otros activadores compatibles pueden refrescar el snapshot completo sin abrir Islemetry."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            diagnosticRow(
                language.text("Last automation start", "Último inicio por automatización"),
                value: backgroundDateText(shortcutLastStarted)
            )

            diagnosticRow(
                language.text("Last automation refresh", "Última actualización por automatización"),
                value: backgroundDateText(shortcutLastCompleted)
            )

            diagnosticRow(
                language.text("Automation result", "Resultado de automatización"),
                value: shortcutResultText
            )

            if !shortcutLastError.isEmpty {
                Text(shortcutLastError)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }

            ShortcutsLink()
                .shortcutsLinkStyle(.automaticOutline)

            Text(
                language.text(
                    "In Shortcuts: Automation → choose a trigger → Run Immediately → add Refresh Islemetry. Every trigger refreshes all available modules and updates the existing Live Activity.",
                    "En Atajos: Automatización → elige un activador → Ejecutar inmediatamente → agrega Actualizar Islemetry. Cada activador refresca todos los módulos disponibles y actualiza la Live Activity existente."
                )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var shortcutResultText: String {
        switch shortcutLastResult {
        case "running":
            return language.text("Running", "Ejecutándose")
        case "success":
            return language.text("Success", "Correcto")
        case "cancelled":
            return language.text("Cancelled", "Cancelado")
        case "failed":
            return language.text("Failed", "Falló")
        default:
            return language.text("Never", "Nunca")
        }
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

                VStack(spacing: 10) {
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
                        if let first = expandedKinds.first {
                            HStack(spacing: 16) {
                                expandedPreviewMetric(first)

                                if expandedKinds.count > 1 {
                                    expandedPreviewMetric(expandedKinds[1])
                                } else {
                                    Spacer(minLength: 0)
                                }
                            }
                        }

                        let remaining = Array(expandedKinds.dropFirst(2))
                        if !remaining.isEmpty {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(remaining) { kind in
                                    expandedPreviewMetric(kind)
                                }
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
                    .lineLimit(1)
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
                    "When enabled, Core Location can wake Islemetry for genuine location changes. Each delivered event refreshes the full telemetry snapshot and local weather.",
                    "Al activarlo, Core Location puede despertar Islemetry por cambios reales de ubicación. Cada evento entregado actualiza el snapshot completo de telemetría y el clima local."
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
                        .lineLimit(1)
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
                        systemImage: "cloud.sun.fill"
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
        Task {
            await refreshSnapshot(startIfNeeded: startIfNeeded)
        }
    }

    @MainActor
    private func refreshAutomaticallyWhileActive() async {
        guard scenePhase == .active else { return }

        while !Task.isCancelled, scenePhase == .active {
            await refreshSnapshot(startIfNeeded: false, onlyIfChanged: true)

            do {
                try await Task.sleep(for: Self.automaticRefreshInterval)
            } catch {
                return
            }
        }
    }

    @MainActor
    private func refreshSnapshot(startIfNeeded: Bool, onlyIfChanged: Bool = false) async {
        telemetry.refresh()
        let configuration = IslandConfiguration.current

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
                configuration: configuration,
                onlyIfChanged: onlyIfChanged
            )
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
