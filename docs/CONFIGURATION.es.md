# Configuración de la Isla Dinámica

**Español** · [English](CONFIGURATION.md)

Islemetry te permite decidir qué métricas del dispositivo aparecen en la Isla Dinámica y personalizar el color usado para el texto y los símbolos de telemetría. La configuración se guarda localmente en el iPhone y se reutiliza la próxima vez que inicies una Live Activity.

## Cambiar lo que muestra la Isla Dinámica

1. Abre **Islemetry**.
2. Toca la tarjeta **Configurar Isla Dinámica**.
3. En **Isla Dinámica compacta**, elige:
   - **Izquierda** — la métrica del lado izquierdo.
   - **Derecha** — la métrica del lado derecho.
4. En **Isla Dinámica expandida**, elige hasta seis métricas adicionales.
5. Selecciona **Ninguna** en las posiciones expandidas que no quieras utilizar.
6. En **Apariencia**, elige el color del texto con el Color Picker de iOS.
7. Toca **Aplicar a Live Activity**.

Si ya hay una Live Activity activa, **Aplicar a Live Activity** la actualiza con la nueva distribución y el nuevo color. Si no hay ninguna actividad activa, la selección queda guardada y se utilizará la próxima vez que pulses **Iniciar**.

## Distribución compacta vs expandida

Las vistas compacta y expandida son ahora independientes:

- **Izquierda / Derecha** se usan únicamente mientras la Isla Dinámica está contraída.
- La vista expandida utiliza directamente las seis posiciones de **Isla Dinámica expandida**.
- Las posiciones 1 y 2 se muestran en las regiones superiores izquierda/derecha.
- Las posiciones 3–6 se muestran en una cuadrícula compacta 2×2 debajo.
- Las métricas compactas Izquierda/Derecha ya no se repiten en la vista expandida.

Esto mantiene la vista expandida en un máximo de seis métricas y evita que las filas inferiores se recorten por la altura disponible de la Isla Dinámica.

## Color del texto de la Isla Dinámica

La sección **Apariencia** utiliza el Color Picker completo de iOS, no una paleta fija.

- Color predeterminado: blanco (`#FFFFFF`).
- La opacidad está desactivada intencionalmente para mantener una legibilidad predecible sobre el fondo negro de la Isla Dinámica.
- El color elegido se guarda localmente como un valor RGB HEX.
- La pantalla de configuración muestra el valor HEX actual.
- **Restablecer a blanco** recupera el valor predeterminado.
- La vista previa de la Isla Dinámica en Inicio utiliza el mismo color seleccionado.
- Al aplicarlo, el color se incluye en el estado de ActivityKit para que una Live Activity activa pueda cambiar de color sin reiniciarse.

El color se utiliza para los valores de telemetría y los símbolos de las métricas en las presentaciones compacta, expandida, mínima y de pantalla bloqueada. Las etiquetas secundarias utilizan el mismo color con menor opacidad para conservar la jerarquía visual.

Los colores muy oscuros pueden tener poco contraste sobre el fondo negro de la Isla Dinámica, por lo que se recomiendan colores claros o brillantes.

## Idioma

Islemetry ofrece tres opciones de idioma:

- **System / Sistema** — sigue el idioma actual de iOS.
- **English** — usa siempre inglés.
- **Español** — usa siempre español.

Cuando seleccionas **System / Sistema**, los idiomas de iOS en español (`es-*`) utilizan Español y cualquier otro idioma del sistema que todavía no soporte Islemetry usa English como respaldo. La preferencia se guarda localmente. Una Live Activity activa recibe el idioma resuelto `en` o `es` cuando Islemetry la actualiza.

## Distribución predeterminada

### Compacta

- Izquierda: Batería
- Derecha: Estado térmico
- Color del texto: Blanco (`#FFFFFF`)

### Expandida

1. Red
2. Almacenamiento libre
3. Memoria total
4. Núcleos activos de CPU
5. Frecuencia máxima de actualización
6. Modo de bajo consumo

## Métricas disponibles

### Energía y temperatura

- Porcentaje de batería
- Estado de carga
- Modo de bajo consumo
- Estado térmico
- Brillo de pantalla

### CPU y memoria

- Número total de núcleos de CPU
- Número de núcleos activos de CPU
- Memoria física total

> `Memory Total` corresponde a la memoria física reportada por `ProcessInfo`. No es un porcentaje global de RAM usada por todo el dispositivo actualizado continuamente.

### Almacenamiento

- Resumen de almacenamiento
- Almacenamiento libre
- Almacenamiento usado
- Almacenamiento total

El almacenamiento se calcula con los valores de capacidad del volumen expuestos por Foundation.

### Pantalla

- Frecuencia máxima de actualización
- Estado/capacidad ProMotion inferido a partir de la frecuencia máxima
- Resolución nativa de pantalla
- Escala nativa de pantalla
- Brillo

> `Max Refresh Rate` es la frecuencia máxima que expone la pantalla. No es una medición en tiempo real de la frecuencia que otra aplicación esté utilizando.

### Red

- Interfaz actual: Wi-Fi, celular, Ethernet, conectado o sin conexión
- Low Data Mode / conexión restringida
- Conexión considerada costosa
- Compatibilidad con IPv4
- Compatibilidad con IPv6
- Compatibilidad con DNS

> `Expensive Network` corresponde a la clasificación del sistema `NWPath.isExpensive`. No representa el costo monetario real de la conexión.

### Dispositivo y sistema

- Identificador de hardware
- Modelo del dispositivo
- iOS / versión del sistema
- Configuración regional
- Zona horaria

## Comportamiento de actualización

La Live Activity muestra el último snapshot de telemetría enviado por Islemetry. iOS no permite que Islemetry se ejecute continuamente en segundo plano como un monitor de sistema de escritorio, por lo que muchas métricas se actualizan cuando la app está activa y envía un nuevo estado a ActivityKit.

El botón **Actualizar** toma un nuevo snapshot y actualiza la Live Activity activa. Los cambios de distribución y color también se pueden enviar con **Aplicar a Live Activity**.

## Privacidad y compatibilidad con App Store

Islemetry utiliza intencionalmente frameworks públicos de Apple. La información de espacio en disco pertenece a las Required Reason APIs; el motivo aprobado por Apple `85F4.1` permite mostrar información de almacenamiento al usuario. UserDefaults se utiliza únicamente para guardar la configuración propia de Islemetry, incluida la selección de métricas, idioma y color del texto, correspondiente al motivo aprobado `CA92.1`.

El uptime del sistema se excluye intencionalmente de esta compilación orientada a App Store porque los motivos aprobados por Apple para la API de tiempo de arranque del sistema no incluyen simplemente mostrar el uptime del dispositivo como estadística de monitorización.
