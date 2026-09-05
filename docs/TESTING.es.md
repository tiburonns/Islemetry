# Islemetry V0.2 — Plan de pruebas en dispositivo real

**Español** · [English](TESTING.md)

Esta lista valida la compilación actual de Islemetry en un iPhone físico con Isla Dinámica. V0.1 ya fue compilada e instalada correctamente en hardware real; V0.2 agrega contenido configurable en la Isla Dinámica, telemetría ampliada, vista previa en Inicio, controles de idioma y color personalizado para el texto de la Isla Dinámica.

## Objetivo

Validar que Islemetry compile, abra correctamente, recopile telemetría, muestre una vista previa fiel de la distribución y color guardados para la Isla Dinámica, cambie de idioma sin reiniciar y pueda crear, actualizar y detener correctamente la Live Activity tanto en la pantalla bloqueada como en la Isla Dinámica.

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
3. Confirma que las 27 métricas actuales se muestren sin SF Symbols faltantes, valores vacíos ni recortes graves.
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

1. Cambia un valor que pueda variar, como estado de batería, carga, red, modo de bajo consumo o brillo.
2. Regresa a Islemetry y pulsa **Refresh / Actualizar**.
3. Revisa nuevamente la vista previa de Inicio y la Live Activity.

### Resultado esperado

- La vista previa de Inicio refleja el nuevo snapshot.
- La Live Activity permanece activa.
- Los valores actualizados se reflejan después de actualizar.
- El color seleccionado se conserva.

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
- Una Live Activity activa se actualiza al cambiar distribución, color o idioma.
- Las presentaciones compacta, expandida, mínima y de pantalla bloqueada se renderizan correctamente cuando estén disponibles.
- La Live Activity puede actualizarse y detenerse sin duplicados ni sesiones residuales.
