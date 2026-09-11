# Islemetry

**Español** · [English](README.md)

**Telemetría del iPhone mediante Live Activities y la Isla Dinámica.**

Islemetry es una aplicación nativa para iOS desarrollada con SwiftUI que convierte la Isla Dinámica en un monitor configurable y visible de un vistazo. Elige la información que te importa, mantén dos métricas visibles en la Isla compacta y mantenla presionada para abrir un snapshot de telemetría más completo.

> **Release actual:** V0.2.0. V0.1 fue compilada, instalada y validada en un iPhone físico; V0.2.0 también supera la validación automatizada de simulador e IPA unsigned para dispositivo y todavía requiere la validación final de Live Activity en hardware compatible.

## Qué hace Islemetry

Islemetry recopila información del dispositivo expuesta mediante frameworks públicos de Apple y envía un snapshot configurable a una Live Activity de ActivityKit.

Puedes elegir:

- Métrica **Izquierda** de la Isla compacta
- Métrica **Derecha** de la Isla compacta
- Hasta **seis métricas expandidas**
- Un **color personalizado para la telemetría de la Isla Dinámica**
- Comportamiento de idioma **Sistema / English / Español**
- Apariencia **Sistema / Clara / Oscura**

La misma Live Activity también aparece en la pantalla bloqueada y la app incluye una vista previa en Inicio que refleja la configuración guardada de la Isla Dinámica y el color de telemetría elegido.

## Funciones actuales

- Iniciar, actualizar y detener una Live Activity
- Presentaciones compacta, mínima, expandida y de pantalla bloqueada
- Métricas Izquierda/Derecha configurables
- Hasta seis métricas configurables en la vista expandida
- Color Picker completo de iOS para texto y símbolos de métricas de la Isla Dinámica
- Color RGB HEX persistente, con blanco (`#FFFFFF`) como valor predeterminado
- Configuración persistente guardada en el dispositivo
- Vista previa en Inicio con exactamente la distribución y el color guardados
- Selector de idioma **Sistema / English / Español**
- Selector persistente de apariencia **Sistema / Clara / Oscura**
- Nombres de métricas, estados, configuración y textos auxiliares de Live Activity según el idioma efectivo
- Cambios de idioma/distribución/color pueden actualizar una Live Activity ya activa
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
git switch main
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

El IPA de la release es una compilación unsigned para dispositivo físico que AltStore Classic vuelve a firmar con la cuenta del usuario. El repositorio no contiene certificados privados, perfiles de aprovisionamiento ni credenciales de cuentas Apple.

Agrega la fuente estable en **AltStore Classic → Browse → Sources → +**:

```text
https://raw.githubusercontent.com/tiburonns/Islemetry/main/altstore/source.json
```

Consulta **[Guía de IPA](docs/IPA.es.md)** para:

- exportación mediante Xcode Organizer
- comandos `xcodebuild` para Archive/exportación
- consideraciones de firma
- scripts de compilación y validación para AltStore
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
├── Resources/
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

altstore/
└── source.json

script/
├── build_altstore_ipa.sh
├── update_altstore_source.py
└── validate_altstore.py
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

Muchas métricas son **snapshots**. Mientras Islemetry está activa, toma automáticamente un snapshot nuevo cada tres segundos y actualiza cualquier Live Activity en ejecución. Las notificaciones del sistema sobre batería, energía, estado térmico, brillo y red también pueden provocar actualizaciones inmediatas. Algunas presentaciones controladas por el sistema pueden continuar mientras el proceso principal está suspendido, pero iOS pausa el ciclo de tres segundos de Islemetry en segundo plano y una app normal suspendida no puede muestrear arbitrariamente CPU/RAM de forma continua.

## Privacidad y orientación a App Store

Islemetry está diseñada para mantener la telemetría local siempre que sea posible y utiliza frameworks públicos de Apple.

Decisiones actuales relacionadas con Required Reason APIs:

- El espacio en disco se muestra al usuario bajo el motivo aprobado `85F4.1`.
- UserDefaults almacena preferencias propias de distribución, idioma, apariencia y color de la Isla Dinámica bajo el motivo aprobado `CA92.1`.
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
2. **V0.2** — Isla configurable + telemetría ampliada + preview + controles de idioma y apariencia ✅ publicada
3. **V0.3** — Perfiles + Shortcuts / App Intents
4. **V0.4** — Diagnóstico de red y telemetría más completa
5. **V0.5** — Módulos opcionales WeatherKit / HealthKit
6. **V1.0** — Release pulido y preparado para App Store

## Logo

El icono de Islemetry combina un pulso de telemetría luminoso en cian y violeta con una cápsula inspirada en la Isla Dinámica sobre un fondo azul marino profundo.

## Repositorio

```text
https://github.com/tiburonns/Islemetry
```

Islemetry está en desarrollo activo y prioriza APIs públicas, comportamiento transparente de telemetría y tecnologías nativas de iOS por encima de APIs privadas de monitorización.
