import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    static let storageKey = "app.language"

    case system = "system"
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    static var current: AppLanguage {
        let rawValue = UserDefaults.standard.string(forKey: storageKey)
        return AppLanguage(rawValue: rawValue ?? AppLanguage.system.rawValue) ?? .system
    }

    var effective: AppLanguage {
        guard self == .system else { return self }

        let preferredLanguage = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return preferredLanguage.hasPrefix("es") ? .spanish : .english
    }

    var displayName: String {
        switch self {
        case .system: return "System / Sistema"
        case .english: return "English"
        case .spanish: return "Español"
        }
    }

    func text(_ english: String, _ spanish: String) -> String {
        effective == .spanish ? spanish : english
    }
}

struct DeviceMetric: Identifiable, Hashable, Codable {
    enum Kind: String, Codable, CaseIterable, Identifiable, Hashable {
        case battery
        case charging
        case lowPower
        case thermal
        case memory
        case storage
        case storageFree
        case storageUsed
        case storageTotal
        case cpuCores
        case activeCpuCores
        case refreshRate
        case promotion
        case displayResolution
        case displayScale
        case brightness
        case network
        case lowDataMode
        case networkExpensive
        case ipv4
        case ipv6
        case dns
        case device
        case deviceModel
        case system
        case locale
        case timeZone

        var id: String { rawValue }

        var selectionTitle: String {
            selectionTitle(language: .current)
        }

        func selectionTitle(language: AppLanguage) -> String {
            switch self {
            case .battery: return language.text("Battery", "Batería")
            case .charging: return language.text("Charging State", "Estado de carga")
            case .lowPower: return language.text("Low Power Mode", "Modo de bajo consumo")
            case .thermal: return language.text("Thermal State", "Estado térmico")
            case .memory: return language.text("Memory Total", "Memoria total")
            case .storage: return language.text("Storage Summary", "Resumen de almacenamiento")
            case .storageFree: return language.text("Storage Free", "Almacenamiento libre")
            case .storageUsed: return language.text("Storage Used", "Almacenamiento usado")
            case .storageTotal: return language.text("Storage Total", "Almacenamiento total")
            case .cpuCores: return language.text("CPU Cores", "Núcleos de CPU")
            case .activeCpuCores: return language.text("Active CPU Cores", "Núcleos CPU activos")
            case .refreshRate: return language.text("Max Refresh Rate", "Frecuencia máxima")
            case .promotion: return "ProMotion"
            case .displayResolution: return language.text("Display Resolution", "Resolución de pantalla")
            case .displayScale: return language.text("Display Scale", "Escala de pantalla")
            case .brightness: return language.text("Brightness", "Brillo")
            case .network: return language.text("Network", "Red")
            case .lowDataMode: return language.text("Low Data Mode", "Modo de datos reducidos")
            case .networkExpensive: return language.text("Expensive Network", "Red costosa")
            case .ipv4: return "IPv4"
            case .ipv6: return "IPv6"
            case .dns: return "DNS"
            case .device: return language.text("Hardware Identifier", "Identificador de hardware")
            case .deviceModel: return language.text("Device Model", "Modelo del dispositivo")
            case .system: return language.text("System", "Sistema")
            case .locale: return language.text("Locale", "Configuración regional")
            case .timeZone: return language.text("Time Zone", "Zona horaria")
            }
        }
    }

    let id: UUID
    let kind: Kind
    let title: String
    let value: String
    let symbol: String
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        value: String,
        symbol: String,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.value = value
        self.symbol = symbol
        self.updatedAt = updatedAt
    }
}
