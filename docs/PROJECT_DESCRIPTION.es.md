# Descripción del proyecto Islemetry

**Español** · [English](PROJECT_DESCRIPTION.md)

## Descripción en una línea

**Telemetría del iPhone mostrada mediante Live Activities y la Isla Dinámica.**

## Descripción corta para GitHub

Islemetry es una app nativa para iOS desarrollada con SwiftUI que muestra telemetría configurable del dispositivo mediante ActivityKit, la pantalla bloqueada y la Isla Dinámica.

## Descripción corta del producto

Islemetry convierte la Isla Dinámica en un monitor compacto del estado del dispositivo. Elige las métricas que te importan, mantenlas visibles mediante una Live Activity y expande la Isla cuando quieras consultar un snapshot más completo de tu iPhone.

## Descripción completa del proyecto

Islemetry es una aplicación de telemetría para iOS diseñada alrededor de Live Activities y la Isla Dinámica.

En lugar de esconder la información del dispositivo dentro de un panel convencional, Islemetry permite que el usuario elija qué métricas desea mantener visibles de un vistazo. Dos métricas pueden asignarse a la Isla Dinámica compacta y hasta seis métricas adicionales pueden mostrarse en la presentación expandida. La misma Live Activity también aparece en la pantalla bloqueada.

Actualmente la aplicación expone información relacionada con energía, estado térmico, CPU, memoria, almacenamiento, pantalla, red y sistema. Algunos ejemplos son porcentaje de batería, estado de carga, Modo de bajo consumo, estado térmico, memoria física, almacenamiento libre/usado/total, número de núcleos de CPU, frecuencia máxima de actualización de pantalla, indicador ProMotion, brillo, interfaz de red actual, Low Data Mode, compatibilidad con IPv4/IPv6/DNS, identificador del dispositivo, versión de iOS, configuración regional y zona horaria.

Islemetry incluye en la pantalla principal una vista previa de la configuración real de la Isla Dinámica compacta y expandida, preferencias persistentes guardadas en el dispositivo y un selector de idioma con modos Sistema, English y Español. Cuando la Live Activity ya está activa, los cambios de distribución e idioma pueden enviarse a la actividad existente sin crear intencionalmente una sesión duplicada.

El proyecto está desarrollado de forma nativa con SwiftUI, ActivityKit, WidgetKit, Network, UIKit y Foundation. Evita intencionalmente dependencias externas en tiempo de ejecución y se desarrolla teniendo en cuenta la compatibilidad con App Store y los requisitos de privacidad de Apple.

Como iOS no permite que una aplicación normal se ejecute continuamente en segundo plano como un monitor de sistema de escritorio, Islemetry trata muchos valores como snapshots de telemetría. La app actualiza esos valores cuando recibe tiempo de ejecución y envía un nuevo estado de ActivityKit a la Live Activity.

## Principios del proyecto

- **Información inmediata:** las métricas importantes deben poder consultarse sin abrir un panel completo.
- **Configurable:** el usuario decide qué aparece en la Isla Dinámica compacta y expandida.
- **Nativo:** utilizar frameworks públicos de Apple e interfaces propias de la plataforma.
- **Privado:** mantener la telemetría del dispositivo local siempre que sea posible.
- **Transparente:** diferenciar valores reales, capacidades inferidas y snapshots.
- **Orientado a App Store:** evitar APIs privadas/no compatibles y documentar el uso de Required Reason APIs.

## Resumen de funciones actuales

- Iniciar, actualizar y detener una Live Activity
- Selección de métricas izquierda/derecha en la Isla Dinámica compacta
- Hasta seis métricas en la vista expandida
- Live Activity en pantalla bloqueada
- Vista previa de la Isla Dinámica en Inicio
- Configuración persistente en el dispositivo
- Modos de idioma Sistema / English / Español
- 27 métricas del dispositivo/sistema
- Sin dependencias externas en tiempo de ejecución

## Topics sugeridos para GitHub

```text
ios
swift
swiftui
activitykit
widgetkit
live-activities
dynamic-island
iphone
telemetry
system-monitor
```

## Texto sugerido para About de GitHub

```text
Telemetría del iPhone mediante Live Activities y la Isla Dinámica.
```

## Subtítulo sugerido para releases

```text
Telemetría configurable del dispositivo para la Isla Dinámica.
```

## Descripción a futuro

La arquitectura está pensada para crecer más allá de V0.2 con perfiles, Shortcuts/App Intents, diagnósticos de red más completos, módulos opcionales de WeatherKit y HealthKit y mejores flujos de Release/distribución.
