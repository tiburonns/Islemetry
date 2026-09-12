# Automatizaciones de Atajos

Islemetry 0.4.0 expone la acción **Actualizar Islemetry** mediante App Intents para Apple Atajos.

La acción actualiza el snapshot completo de telemetría disponible y la Live Activity existente. Por eso, una automatización activada por Cargador, Wi-Fi, Bluetooth, Modo de bajo consumo, nivel de batería, Concentración, Modo avión u otro activador compatible actualiza todos los módulos de Islemetry que iOS permita leer en ese momento.

## Primer inicio

Instala y abre Islemetry 0.4.0 al menos una vez. Islemetry registra su App Shortcut con el sistema durante el inicio.

Dentro de Islemetry, abre la tarjeta **Automatizaciones de Atajos** y toca el botón de Atajos. Debe aparecer la acción **Actualizar Islemetry** en la página de Islemetry dentro de Atajos.

## Automatizaciones recomendadas

Crea cada automatización en **Atajos → Automatización → +**. Elige el activador, selecciona **Ejecutar inmediatamente** y agrega la acción **Actualizar Islemetry**.

Conjunto inicial recomendado:

1. Cargador → Está conectado
2. Cargador → Está desconectado
3. Wi-Fi → Cualquier red
4. Bluetooth → Cualquier dispositivo, o dispositivos seleccionados
5. Modo de bajo consumo → Está activado
6. Modo de bajo consumo → Está desactivado
7. Nivel de batería → Menor que 20 %
8. Nivel de batería → Mayor que 80 %
9. Modo avión → Está activado
10. Modo avión → Está desactivado

También puedes usar Concentración, CarPlay, NFC, apertura/cierre de apps y otros activadores de automatización personal cuando sean útiles.

## Qué ocurre cuando se activa una automatización

La automatización ejecuta **Actualizar Islemetry**. Islemetry entonces:

1. Lee un snapshot completo de telemetría actual.
2. Da al monitor de red una breve oportunidad para publicar la ruta actual.
3. Actualiza la Live Activity existente mediante ActivityKit.
4. Reutiliza la última ubicación autorizada para refrescar el clima cuando corresponde.
5. Guarda la hora de inicio, finalización y resultado para mostrar diagnóstico dentro de la app.

El activador no actualiza únicamente su propia métrica. Por ejemplo, una automatización de Cargador hace que Islemetry vuelva a leer batería, estado de carga, red, estado térmico, almacenamiento, pantalla, información del dispositivo/sistema, caché de ubicación/clima y todas las demás métricas disponibles.

## Comportamiento importante de iOS

App Intents está diseñado para funcionar desde experiencias del sistema como Atajos, e Islemetry solicita ejecución en segundo plano para la acción de actualización en las versiones compatibles de iOS. El sistema sigue controlando los recursos de ejecución y puede cancelar el trabajo en condiciones excepcionales.

Las automatizaciones personales son específicas de cada dispositivo. Debes crearlas en cada iPhone o iPad donde quieras que se ejecuten.
