# Islemetry

**Español** · [English](README.md)

**Telemetría en vivo del iPhone mostrada mediante Live Activities y la Isla Dinámica.**

Islemetry es una app nativa para iOS construida con SwiftUI y enfocada en mostrar información del dispositivo de forma rápida y visible. Recopila métricas que el usuario puede consultar y presenta una selección compacta mediante ActivityKit en la pantalla bloqueada y la Isla Dinámica.

## Alcance de V0.1

- Nivel de batería y estado de carga
- Modo de bajo consumo
- Estado térmico
- Capacidad de memoria física
- Capacidad y espacio disponible de almacenamiento
- Número de núcleos de CPU
- Frecuencia máxima de actualización de pantalla
- Estado de red (Wi-Fi / celular / cableada / sin conexión)
- Identificador del modelo de iPhone y versión de iOS
- Iniciar, actualizar y detener una Live Activity
- Diseños compacto, mínimo, expandido y de pantalla bloqueada

## Arquitectura

```text
Islemetry/
├── App/
├── Models/
└── Services/
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

La arquitectura de V0.1 mantiene la telemetría en el dispositivo. Antes de una distribución por App Store, cada Required Reason API utilizada por la compilación final deberá declararse en `PrivacyInfo.xcprivacy` con el motivo aprobado por Apple correspondiente.

## Política de documentación

Toda la documentación importante del proyecto se mantendrá tanto en inglés como en español. Los archivos en inglés usan el nombre predeterminado y las traducciones al español utilizan el sufijo `.es.md`.

Ejemplos:

- `README.md` / `README.es.md`
- `docs/TESTING.md` / `docs/TESTING.es.md`

Cuando cambien el comportamiento, la arquitectura, los procedimientos de prueba, los requisitos de privacidad o el roadmap, ambas versiones deberán actualizarse juntas.

## Pruebas en dispositivo real

El primer procedimiento de validación en hardware está documentado en [docs/TESTING.es.md](docs/TESTING.es.md).

## Roadmap

1. **V0.1** — Snapshot básico del dispositivo + Live Activity en la Isla Dinámica
2. **V0.2** — Métricas configurables y perfiles
3. **V0.3** — Shortcuts / App Intents
4. **V0.4** — Diagnóstico de red y telemetría ampliada
5. **V0.5** — Módulos opcionales de WeatherKit / HealthKit
6. **V1.0** — Versión pulida y preparada para App Store

## Estado del proyecto

Desarrollo inicial. El primer milestone usa intencionalmente frameworks públicos de Apple y ninguna dependencia externa de terceros.
