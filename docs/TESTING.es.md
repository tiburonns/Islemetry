# Islemetry V0.1 — Plan de pruebas en dispositivo real

**Español** · [English](TESTING.md)

Esta lista está pensada para la primera instalación de Islemetry en un iPhone físico con Isla Dinámica.

## Objetivo

Validar que la app compile, se firme correctamente, se abra, recopile el snapshot inicial de telemetría y pueda crear, actualizar y detener correctamente la Live Activity tanto en la pantalla bloqueada como en la Isla Dinámica.

## Entorno de prueba

Registra lo siguiente antes de comenzar:

- Fecha y hora
- Modelo de Mac
- Versión de macOS
- Versión de Xcode
- Modelo de iPhone
- Versión de iOS
- Equipo de Apple Developer utilizado para la firma
- Commit / rama probada

## Compilación e instalación

1. Abre `Islemetry.xcodeproj` en Xcode.
2. Selecciona el target `Islemetry`.
3. En **Signing & Capabilities**, selecciona tu equipo de Apple Developer.
4. Confirma que la app principal y la extensión `IslemetryWidgets` tengan identificadores de bundle válidos y únicos.
5. Selecciona el iPhone físico como destino de ejecución.
6. Compila y ejecuta la app.

### Resultado esperado

- Xcode completa la compilación sin errores.
- Islemetry se instala en el iPhone.
- Islemetry abre sin cerrarse inesperadamente.

## Prueba de la app principal

1. Abre Islemetry.
2. Revisa la telemetría mostrada en la app.
3. Confirma que aparezcan los siguientes valores cuando sean compatibles:
   - Nivel de batería
   - Estado de carga
   - Modo de bajo consumo
   - Estado térmico
   - Memoria física
   - Almacenamiento
   - Número de núcleos de CPU
   - Frecuencia máxima de actualización de pantalla
   - Estado de red
   - Identificador del dispositivo
   - Versión de iOS

### Registra

Para cualquier valor incorrecto o ausente, captura:

- Nombre de la métrica
- Valor mostrado
- Valor esperado, si se conoce
- Captura de pantalla
- Si volver a abrir la app cambia el resultado

## Prueba de inicio de Live Activity

1. En Islemetry, inicia la Live Activity.
2. Regresa a la pantalla de inicio.
3. Bloquea el iPhone.
4. Desbloquea el iPhone.
5. Observa la Isla Dinámica.

### Resultado esperado

- La Live Activity inicia correctamente.
- La presentación de pantalla bloqueada es visible.
- La presentación compacta de la Isla Dinámica es visible.
- Al mantener presionada la Isla Dinámica aparece la vista expandida.
- No se crean Live Activities duplicadas de forma no intencional.

## Prueba de actualización de Live Activity

1. Anota la telemetría mostrada actualmente.
2. Cambia un valor que pueda variar razonablemente, como estado de batería, estado de carga, red o Modo de bajo consumo.
3. Regresa a Islemetry y pulsa **Refresh**.
4. Revisa nuevamente la Live Activity.

### Resultado esperado

- La Live Activity permanece activa.
- Los valores actualizados se reflejan después del refresh.
- La Live Activity no desaparece ni se duplica.

## Prueba de detención de Live Activity

1. Pulsa **Stop** en Islemetry.
2. Revisa la Isla Dinámica.
3. Revisa la pantalla bloqueada.

### Resultado esperado

- La Live Activity termina correctamente.
- Islemetry desaparece de la Isla Dinámica.
- Islemetry desaparece de la pantalla bloqueada cuando el sistema complete la retirada.

## Prueba de estados y presentación

Comprueba la app y la Live Activity en estados comunes:

- iPhone desbloqueado
- iPhone bloqueado
- Always-On Display, si el dispositivo lo soporta
- Modo de bajo consumo activado/desactivado
- Wi-Fi conectado
- Conexión celular
- Modo avión / sin conexión
- Cargando / desconectado del cargador

## Plantilla para reportar fallos

Usa este formato cuando encuentres un problema:

```text
Prueba:
Dispositivo:
iOS:
Xcode:
Rama / commit:

Esperado:

Resultado real:

Pasos para reproducir:
1.
2.
3.

Error de Xcode o salida de consola:

Captura / grabación de pantalla:
```

## Criterios de aceptación de V0.1

La validación de hardware de V0.1 se considera exitosa cuando:

- El proyecto compila en un iPhone físico.
- La app abre de forma confiable.
- La telemetría principal es visible.
- Se puede iniciar una Live Activity.
- Se renderizan las presentaciones compacta, expandida y de pantalla bloqueada.
- La Live Activity puede actualizarse.
- La Live Activity puede detenerse sin dejar una sesión activa no deseada.

Cualquier problema de compilación, firma, ActivityKit, diseño o métricas encontrado durante esta prueba debe documentarse antes de fusionar el PR de bootstrap.
