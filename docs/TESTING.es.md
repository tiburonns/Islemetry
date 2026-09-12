# Islemetry V0.2 — Plan de pruebas en dispositivo real

**Español** · [English](TESTING.md)

Esta lista valida la compilación actual de Islemetry en un iPhone físico con Isla Dinámica. V0.1 ya fue compilada e instalada correctamente en hardware real; V0.2 agrega contenido configurable en la Isla Dinámica, telemetría ampliada, vista previa en Inicio, controles de idioma y apariencia, y color personalizado para el texto de la Isla Dinámica.

## Objetivo

Validar que Islemetry compile, abra correctamente, recopile telemetría, muestre una vista previa fiel de la distribución y color guardados para la Isla Dinámica, cambie de idioma y apariencia sin reiniciar y pueda crear, actualizar y detener correctamente la Live Activity tanto en la pantalla bloqueada como en la Isla Dinámica.

## Entorno de prueba

Registra:

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

## Prueba de telemetría de la app principal

1. Abre Islemetry.
2. Revisa todas las tarjetas de métricas.
3. Confirma que las 31 métricas actuales se muestren sin SF Symbols faltantes, valores vacíos ni recortes graves.
4. Compara valores fáciles de verificar: batería, carga, modo de bajo consumo, almacenamiento, frecuencia de pantalla, brillo, red, versión de iOS, configuración regional y zona horaria.

## Prueba de vista previa de la Isla Dinámica

1. En Inicio, localiza **Vista previa de Isla Dinámica**.
2. Confirma que la vista compacta muestre las métricas actuales de Izquierda y Derecha con sus valores actuales.
3. Confirma que la vista expandida muestre las métricas expandidas seleccionadas.
4. Abre **Configurar Isla Dinámica** y cambia Izquierda, Derecha y al menos tres posiciones expandidas.
5. Configura al menos una posición expandida como **Ninguna**.
6. Regresa a Inicio.

### Resultado esperado

- La vista previa de Inicio coincide con la configuración guardada.
- Una posición configurada como Ninguna no aparece en la vista expandida.
- La vista previa usa los valores del snapshot de telemetría más reciente.
- Las selecciones expandidas duplicadas no generan tarjetas duplicadas.

## Prueba de color de la Isla Dinámica

1. Abre **Configurar Isla Dinámica**.
2. En **Apariencia**, abre **Color del texto**.
3. Elige un color claramente visible como cian, verde, amarillo o magenta.
4. Confirma que el valor HEX mostrado cambie.
5. Regresa a Inicio y verifica que las vistas previa compacta y expandida usen el color seleccionado.
6. Vuelve a abrir la configuración y pulsa **Restablecer a blanco**.
7. Confirma que el valor HEX regrese a `#FFFFFF`.

### Resultado esperado

- El Color Picker completo de iOS abre correctamente.
- El color elegido se guarda como valor HEX.
- La vista previa de Inicio refleja el color seleccionado.
- Restablecer recupera el blanco.
- Cerrar Islemetry por completo y volver a abrirla conserva el último color guardado.

## Prueba de idioma

1. Prueba **System / Sistema**, **English** y **Español**.
2. Revisa la tarjeta de estado, botones, selector de idioma, vista previa de Isla Dinámica, tarjeta de configuración, nombres de métricas y valores traducibles.
3. En modo Sistema, confirma que iOS en español use Español y que los idiomas todavía no soportados utilicen English como respaldo.
4. Cierra Islemetry por completo, vuelve a abrirla y confirma que se conserve la última preferencia de idioma.

### Resultado esperado

- La interfaz visible utiliza el idioma efectivo.
- Los nombres de métricas y valores traducibles cambian de idioma.
- La selección de idioma persiste al volver a abrir la app.
- Cambiar el idioma no borra la configuración guardada de métricas ni color.

## Prueba de apariencia de la app

1. Selecciona **Sistema**, **Claro** y **Oscuro** en la tarjeta Apariencia.
2. En cada modo revisa la barra de navegación, tarjetas, controles segmentados, etiquetas, botones, cuadrícula de métricas y vista previa de Isla Dinámica.
3. En modo Sistema, cambia la apariencia del iPhone desde el Centro de control o Ajustes y vuelve a Islemetry.
4. Cierra la app por completo y vuelve a abrirla después de seleccionar Oscuro.

### Resultado esperado

- Claro y Oscuro se aplican de inmediato sin reiniciar.
- Sistema sigue la apariencia actual de iOS.
- Texto, materiales, controles y fondos conservan contraste legible en los tres modos.
- La vista previa de Isla Dinámica sigue siendo negra y conserva su color de telemetría configurado.
- La apariencia elegida persiste al volver a abrir la app.

## Prueba de inicio de Live Activity

1. Configura la Isla Dinámica como prefieras, incluyendo un color distinto de blanco.
2. Inicia la Live Activity.
3. Regresa a la pantalla de inicio.
4. Bloquea el iPhone y revisa la pantalla bloqueada.
5. Desbloquea el iPhone y revisa la Isla Dinámica compacta.
6. Mantén presionada la Isla Dinámica y revisa la presentación expandida.

### Resultado esperado

- La Live Activity inicia correctamente.
- La Isla Dinámica compacta coincide con las selecciones Izquierda y Derecha.
- La vista expandida contiene las métricas seleccionadas esperadas.
- El color seleccionado aparece en el texto y símbolos de telemetría de la Isla Dinámica.
- La presentación de pantalla bloqueada utiliza el color seleccionado.
- No se crean Live Activities duplicadas accidentalmente.

## Prueba de actualización de configuración y color con Live Activity activa

1. Mantén la Live Activity activa.
2. Cambia Izquierda, Derecha, las posiciones expandidas y el color del texto en Islemetry.
3. Pulsa **Aplicar a Live Activity**.
4. Revisa nuevamente las presentaciones compacta, expandida, mínima cuando esté disponible y de pantalla bloqueada.

### Resultado esperado

- La Live Activity existente permanece activa.
- Su contenido cambia a la nueva distribución seleccionada.
- El color del texto y símbolos cambia sin finalizar la actividad.
- Las etiquetas secundarias utilizan el mismo color con menor opacidad.
- No se crea una segunda Live Activity.

## Prueba de cambio de idioma con Live Activity activa

1. Mantén la Live Activity activa en inglés.
2. Abre Islemetry y cambia a **Español**.
3. Regresa a la Isla Dinámica y a la vista expandida.
4. Repite con modo Sistema y English.

### Resultado esperado

- Islemetry envía automáticamente un nuevo estado de ActivityKit después de cambiar el idioma.
- Los nombres de métricas y valores traducibles utilizan el idioma efectivo.
- Los textos auxiliares como Updated / Actualizado cambian correctamente.
- El color personalizado no cambia al cambiar el idioma.
- La actividad sigue siendo la misma sesión y no se duplica.

## Prueba de actualización de Live Activity

1. Inicia una Live Activity y observa el tiempo relativo de **Última captura**.
2. Mantén Islemetry en primer plano durante al menos cuatro segundos sin pulsar ningún botón.
3. Confirma que **Última captura** avanza y revisa la vista previa de Inicio y la Live Activity.
4. Pulsa **Refresh / Actualizar** y confirma que todavía solicita una actualización inmediata.

### Resultado esperado

- Se toma un snapshot nuevo aproximadamente cada tres segundos mientras la app está activa.
- La vista previa de Inicio refleja el nuevo snapshot.
- La Live Activity permanece activa.
- Los valores nuevos se envían automáticamente y después de una actualización manual.
- El color seleccionado se conserva.
- Al enviar Islemetry a segundo plano, el ciclo de tres segundos se detiene hasta que la app vuelve a estar activa.

## Prueba de detención de Live Activity

1. Pulsa **Stop / Detener** en Islemetry.
2. Revisa la Isla Dinámica.
3. Revisa la pantalla bloqueada.

### Resultado esperado

- La Live Activity termina correctamente.
- Islemetry desaparece de la Isla Dinámica.
- Islemetry desaparece de la pantalla bloqueada cuando el sistema complete la retirada.

## Plantilla para reportar fallos

```text
Prueba:
Dispositivo:
iOS:
Xcode:
Rama / commit:
Idioma:
Color HEX:

Esperado:

Resultado real:

Pasos para reproducir:
1.
2.
3.

Error de Xcode o salida de consola:

Captura / grabación de pantalla:
```

## Criterios de aceptación de V0.2

La validación de hardware de V0.2 se considera exitosa cuando:

- El proyecto compila y abre en un iPhone físico.
- Todas las tarjetas de métricas actuales se muestran correctamente.
- La vista previa de Isla Dinámica en Inicio coincide con la configuración y el color guardados.
- Las selecciones compactas y expandidas pueden cambiarse y persisten.
- El color del texto de la Isla Dinámica puede cambiarse, restablecerse, aplicarse y persistir.
- El comportamiento Sistema / English / Español funciona y persiste.
- La apariencia Sistema / Clara / Oscura funciona, conserva la legibilidad y persiste.
- Una Live Activity activa se actualiza al cambiar distribución, color o idioma.
- Las presentaciones compacta, expandida, mínima y de pantalla bloqueada se renderizan correctamente cuando estén disponibles.
- La Live Activity puede actualizarse y detenerse sin duplicados ni sesiones residuales.


## Prueba de ubicación y clima local

1. Instala la compilación más reciente en un iPhone físico.
2. Abre **Ubicación y clima**.
3. Pulsa **Permitir ubicación** y concede acceso.
4. Pulsa **Actualizar clima**.
5. Confirma que **Temperatura local**, **Sensación térmica**, **Clima** y **Ubicación** muestren valores y no el estado de espera.
6. Asigna **Temperatura local** a Izquierda o Derecha.
7. Aplica la configuración a una Live Activity activa.
8. Confirma que la temperatura aparezca en la Isla Dinámica.
9. Abre el enlace de atribución de Open-Meteo.

### Resultado esperado

- El estado de permiso se actualiza correctamente.
- La temperatura local se muestra en °C.
- La sensación térmica y condición meteorológica se muestran correctamente.
- La métrica meteorológica seleccionada aparece en la Live Activity.
- La atribución es visible y se puede tocar.

## Prueba de ubicación en segundo plano

1. Activa **Ubicación en segundo plano**.
2. Sigue cualquier aviso adicional de permisos de iOS.
3. Confirma que Islemetry muestre **Siempre** si iOS lo concede.
4. Mantén una Live Activity activa con Temperatura local seleccionada.
5. Envía Islemetry a segundo plano.
6. Desplázate lo suficiente para generar un evento de Core Location o usa la simulación de ubicación de Xcode.
7. Revisa la Live Activity existente después de que iOS entregue la actualización.
8. Desactiva **Ubicación en segundo plano**.

### Resultado esperado

- No se crea una Live Activity duplicada.
- La ubicación en segundo plano solo está activa cuando se habilita explícitamente.
- Un evento entregado en segundo plano puede actualizar el clima y la Live Activity existente.
- Desactivar el interruptor detiene las actualizaciones estándar de ubicación en segundo plano.
- No se presupone un intervalo fijo; iOS controla la planificación.


## Prueba de actualización completa en segundo plano

1. Instala Islemetry 0.3.1 en un iPhone físico.
2. Inicia una Live Activity con métricas fáciles de observar, por ejemplo Batería, Energía, Térmico, Red, Almacenamiento libre y Temperatura local.
3. Confirma que en primer plano continúe la actualización aproximadamente cada 3 segundos.
4. Envía Islemetry a segundo plano; no la cierres a la fuerza.
5. Confirma que **Actualización en segundo plano** esté permitida en los ajustes de iOS.
6. Deja la Live Activity activa y permite que iOS ejecute la tarea programada.
7. Vuelve a abrir Islemetry y confirma que no se haya creado una Live Activity duplicada.
8. Si Ubicación en segundo plano está activada, un evento entregado de ubicación también debe actualizar el snapshot completo de telemetría.

### Resultado esperado

- El registro de `BGTaskScheduler` no provoca un crash al iniciar.
- El target principal contiene `fetch` y `location` en `UIBackgroundModes`.
- `com.tiburonns.islemetry.refresh` aparece en `BGTaskSchedulerPermittedIdentifiers`.
- Una tarea en segundo plano actualiza el arreglo completo de métricas y la Live Activity existente.
- Los eventos de ubicación también actualizan todas las métricas antes/junto con el clima.
- No se promete una cadencia fija de 3 segundos ni 15 minutos en segundo plano; iOS decide el momento real.

> Para pruebas de segundo plano, envía Islemetry al Home pero **no la cierres a la fuerza** desde el selector de apps. Después de un cierre forzado, iOS puede no volver a lanzar la app en segundo plano hasta que el usuario la abra manualmente otra vez.
