# Islemetry

**Español** · [English](README.md)

**Telemetría en vivo del iPhone mostrada mediante Live Activities y la Isla Dinámica.**

Islemetry es una app nativa para iOS construida con SwiftUI y enfocada en mostrar información del dispositivo de forma rápida y visible. Recopila métricas consultables por el usuario y presenta una selección configurable mediante ActivityKit en la pantalla bloqueada y la Isla Dinámica.

## Funciones actuales

- Iniciar, actualizar y detener una Live Activity
- Diseños compacto, mínimo, expandido y de pantalla bloqueada
- Métricas **Leading** y **Trailing** configurables por el usuario
- Hasta seis métricas configurables en la vista expandida
- Configuración de la Isla Dinámica persistente y guardada localmente
- 27 métricas disponibles del dispositivo y del sistema
- Sin dependencias externas en tiempo de ejecución

### Categorías de métricas

- **Energía:** batería, estado de carga, modo de bajo consumo, estado térmico, brillo
- **CPU / memoria:** núcleos de CPU, núcleos activos, memoria física total
- **Almacenamiento:** resumen, libre, usado, total
- **Pantalla:** frecuencia máxima, indicador ProMotion, resolución nativa, escala nativa
- **Red:** interfaz, Low Data Mode, conexión considerada costosa, IPv4, IPv6, DNS
- **Dispositivo / sistema:** identificador de hardware, modelo, versión de iOS, configuración regional, zona horaria

Consulta [docs/CONFIGURATION.es.md](docs/CONFIGURATION.es.md) para la guía completa de configuración de la Isla Dinámica y las notas sobre cada métrica.

## Arquitectura

```text
Islemetry/
├── App/
├── Models/
├── Services/
├── Info.plist
└── PrivacyInfo.xcprivacy
Shared/
└── DeviceActivityAttributes.swift
IslemetryWidgets/
├── IslemetryWidgetsBundle.swift
├── IslemetryLiveActivity.swift
└── Info.plist
```

## Frameworks de Apple

- SwiftUI
- ActivityKit
- WidgetKit
- Network
- UIKit
- Foundation

## Privacidad

Islemetry está diseñada para mantener la telemetría en el dispositivo. La información de espacio en disco se utiliza para mostrar almacenamiento al usuario, correspondiente al motivo `85F4.1` de las Required Reason APIs de Apple. UserDefaults guarda únicamente las preferencias propias de visualización de Islemetry, correspondiente al motivo `CA92.1`.

El uptime del sistema se excluye intencionalmente del catálogo orientado a App Store porque los motivos aprobados por Apple para la API de tiempo de arranque del sistema no incluyen mostrar el uptime como una estadística general de monitorización del dispositivo.

## Política de documentación

Toda la documentación importante del proyecto se mantiene tanto en inglés como en español. Los archivos en inglés utilizan el nombre predeterminado y las traducciones al español utilizan el sufijo `.es.md`.

Ejemplos:

- `README.md` / `README.es.md`
- `docs/TESTING.md` / `docs/TESTING.es.md`
- `docs/CONFIGURATION.md` / `docs/CONFIGURATION.es.md`

Cuando cambien el comportamiento, la arquitectura, los procedimientos de prueba, los requisitos de privacidad o el roadmap, ambas versiones deberán actualizarse juntas.

## Pruebas en dispositivo real

El procedimiento de validación en hardware está documentado en [docs/TESTING.es.md](docs/TESTING.es.md).

V0.1 ya fue compilada, instalada y validada correctamente en un iPhone real. La rama actual amplía esa base funcional con contenido configurable en la Isla Dinámica y telemetría adicional.

## Roadmap

1. **V0.1** — Snapshot básico del dispositivo + Live Activity en la Isla Dinámica ✅ validado en hardware
2. **V0.2** — Métricas configurables en la Isla Dinámica + telemetría ampliada 🚧 actual
3. **V0.3** — Perfiles + Shortcuts / App Intents
4. **V0.4** — Diagnóstico de red y telemetría ampliada
5. **V0.5** — Módulos opcionales de WeatherKit / HealthKit
6. **V1.0** — Versión pulida y preparada para App Store

## Estado del proyecto

Desarrollo activo. Islemetry utiliza intencionalmente frameworks públicos de Apple y ninguna dependencia externa en tiempo de ejecución.
