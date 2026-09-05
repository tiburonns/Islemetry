# Islemetry

**Español** · [English](README.md)

**Telemetría del iPhone mediante Live Activities y la Isla Dinámica.**

Islemetry es una aplicación nativa para iOS desarrollada con SwiftUI que convierte la Isla Dinámica en un monitor configurable y visible de un vistazo. Elige la información que te importa, mantén dos métricas visibles en la Isla compacta y mantenla presionada para abrir un snapshot de telemetría más completo.

> **Estado de desarrollo:** V0.2 en desarrollo activo. V0.1 ya fue compilada, instalada y validada en un iPhone físico.

## Qué hace Islemetry

Islemetry recopila información del dispositivo expuesta mediante frameworks públicos de Apple y envía un snapshot configurable a una Live Activity de ActivityKit.

Puedes elegir:

- Métrica **Izquierda** de la Isla compacta
- Métrica **Derecha** de la Isla compacta
- Hasta **seis métricas expandidas**
- Comportamiento de idioma **Sistema / English / Español**

La misma Live Activity también aparece en la pantalla bloqueada y la app incluye una vista previa en Inicio que refleja la configuración guardada de la Isla Dinámica.

## Funciones actuales

- Iniciar, actualizar y detener una Live Activity
- Presentaciones compacta, mínima, expandida y de pantalla bloqueada
- Métricas Izquierda/Derecha configurables
- Hasta seis métricas configurables en la vista expandida
- Configuración persistente guardada en el dispositivo
- Vista previa en Inicio con exactamente la distribución guardada
- Selector de idioma **Sistema / English / Español**
- Nombres de métricas, estados, configuración y textos auxiliares de Live Activity según el idioma efectivo
- Cambios de idioma/distribución pueden actualizar una Live Activity ya activa
- 27 métricas actuales del dispositivo/sistema
- Sin dependencias externas en tiempo de ejecución

### Categorías de métricas

- **Energía:** batería, estado de carga, Modo de bajo consumo, estado térmico, brillo
- **CPU / memoria:** núcleos de CPU, núcleos activos, memoria física total
- **Almacenamiento:** resumen, libre, usado, total
- **Pantalla:** frecuencia máxima, indicador ProMotion, resolución nativa, escala nativa
- **Red:** interfaz actual, Low Data Mode, conexión considerada costosa, IPv4, IPv6, DNS
- **Dispositivo / sistema:** identificador de hardware, modelo, versión de iOS, configuración regional, zona horaria

## Inicio rápido

Clona el repositorio:

```bash
git clone https://github.com/tiburonns/Islemetry.git
cd Islemetry
git switch bootstrap/v0.1
open Islemetry.xcodeproj
```

Después, en Xcode:

1. Selecciona tu equipo de Apple Developer para `Islemetry`.
2. Selecciona el mismo equipo para `IslemetryWidgets`.
3. Conecta un iPhone físico.
4. Selecciónalo como destino de ejecución.
5. Presiona `⌘R`.

Consulta la guía completa en **[Comenzar con Islemetry](docs/GETTING_STARTED.es.md)**.

## IPA

No necesitas un IPA para instalar Islemetry directamente desde Xcode.

Un archivo `.ipa` distribuible debe generarse a partir de un Xcode Archive correctamente firmado. El repositorio no contiene certificados privados, perfiles de aprovisionamiento, credenciales ni un IPA universal prefirmado.

Consulta **[Guía de IPA](docs/IPA.es.md)** para:

- exportación mediante Xcode Organizer
- comandos `xcodebuild` para Archive/exportación
- consideraciones de firma
- opciones de instalación
- checklist para GitHub Releases

## Descripción del proyecto

La descripción corta/larga reutilizable, texto para About de GitHub, topics sugeridos y copy del producto están en **[Descripción del proyecto](docs/PROJECT_DESCRIPTION.es.md)**.

Descripción corta:

> Islemetry es una app nativa para iOS desarrollada con SwiftUI que muestra telemetría configurable del dispositivo mediante ActivityKit, la pantalla bloqueada y la Isla Dinámica.

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

docs/
├── GETTING_STARTED.md / GETTING_STARTED.es.md
├── IPA.md / IPA.es.md
├── PROJECT_DESCRIPTION.md / PROJECT_DESCRIPTION.es.md
├── CONFIGURATION.md / CONFIGURATION.es.md
└── TESTING.md / TESTING.es.md
```

## Frameworks de Apple

- SwiftUI
- ActivityKit
- WidgetKit
- Network
- UIKit
- Foundation

## Modelo de actualización en segundo plano

Islemetry no pretende simular un monitor de escritorio ejecutándose continuamente en segundo plano cuando iOS no lo permite.

Muchas métricas son **snapshots**. Islemetry las actualiza cuando recibe tiempo de ejecución y después envía un nuevo estado a ActivityKit. Algunas presentaciones controladas por el sistema pueden continuar mientras el proceso principal está suspendido, pero una app normal suspendida no puede muestrear arbitrariamente CPU/RAM de forma continua.

## Privacidad y orientación a App Store

Islemetry está diseñada para mantener la telemetría local siempre que sea posible y utiliza frameworks públicos de Apple.

Decisiones actuales relacionadas con Required Reason APIs:

- El espacio en disco se muestra al usuario bajo el motivo aprobado `85F4.1`.
- UserDefaults almacena preferencias propias de distribución/idioma bajo el motivo aprobado `CA92.1`.
- El uptime general del dispositivo se excluye intencionalmente porque los motivos aprobados para la API correspondiente no incluyen usarlo como una estadística genérica de monitor de sistema.

Nunca deben almacenarse credenciales de firma ni material privado de cuentas Apple en este repositorio.

## Documentación

Toda la documentación importante de Islemetry se mantiene en **inglés y español**. Inglés usa el nombre predeterminado y español utiliza `.es.md`.

- [Getting Started](docs/GETTING_STARTED.md) · [Comenzar](docs/GETTING_STARTED.es.md)
- [IPA Guide](docs/IPA.md) · [Guía IPA](docs/IPA.es.md)
- [Project Description](docs/PROJECT_DESCRIPTION.md) · [Descripción del proyecto](docs/PROJECT_DESCRIPTION.es.md)
- [Dynamic Island Configuration](docs/CONFIGURATION.md) · [Configuración](docs/CONFIGURATION.es.md)
- [Testing](docs/TESTING.md) · [Pruebas](docs/TESTING.es.md)

Cuando cambien funcionalidad, arquitectura, instalación, privacidad o distribución, ambas versiones deberán actualizarse juntas.

## Roadmap

1. **V0.1** — Snapshot principal + Live Activity en Isla Dinámica ✅ validado en hardware
2. **V0.2** — Isla configurable + telemetría ampliada + preview + controles de idioma 🚧 actual
3. **V0.3** — Perfiles + Shortcuts / App Intents
4. **V0.4** — Diagnóstico de red y telemetría más completa
5. **V0.5** — Módulos opcionales WeatherKit / HealthKit
6. **V1.0** — Release pulido y preparado para App Store

## Logo

La identidad seleccionada de Islemetry combina la letra **I** con una onda azul de telemetría sobre un icono cuadrado oscuro con esquinas redondeadas. El App Icon final utilizará únicamente el símbolo para conservar legibilidad en tamaños pequeños de iOS.

## Repositorio

```text
https://github.com/tiburonns/Islemetry
```

Islemetry está en desarrollo activo y prioriza APIs públicas, comportamiento transparente de telemetría y tecnologías nativas de iOS por encima de APIs privadas de monitorización.
