# Islemetry 0.2.1

**Español · [English](RELEASE_0.2.1.md)**

Release de mantenimiento enfocada en actualizaciones automáticas de telemetría y entrega eficiente de Live Activities.

## Cambios

- Actualiza el snapshot de telemetría dentro de la app cada tres segundos mientras Islemetry está activa.
- Actualiza inmediatamente al volver a foreground.
- Sólo envía una actualización de Live Activity cuando cambia el payload visible o su configuración.
- Mantiene refresh por eventos de batería, energía, estado térmico, brillo y red.
- Cancela el muestreo periódico cuando iOS manda la app a background o la suspende.

## Distribución

- Versión: `0.2.1`
- Build: `3`
- iOS mínimo: `17.0`
- Se mantiene soporte para AltStore Classic.

El ciclo de tres segundos es de foreground; el background depende de oportunidades/eventos concedidos por iOS y no ofrece un intervalo fijo.
