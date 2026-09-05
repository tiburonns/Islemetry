# Configuración de la Isla Dinámica

**Español** · [English](CONFIGURATION.md)

Islemetry te permite decidir qué métricas del dispositivo aparecen en la Isla Dinámica. La configuración se guarda localmente en el iPhone y se reutiliza la próxima vez que inicies una Live Activity.

## Cambiar lo que muestra la Isla Dinámica

1. Abre **Islemetry**.
2. Toca la tarjeta **Dynamic Island**.
3. En **Compact Dynamic Island**, elige:
   - **Leading** — la métrica del lado izquierdo.
   - **Trailing** — la métrica del lado derecho.
4. En **Expanded Dynamic Island**, elige hasta seis métricas adicionales.
5. Selecciona **None** en las posiciones expandidas que no quieras utilizar.
6. Toca **Apply to Live Activity**.

Si ya hay una Live Activity activa, **Apply to Live Activity** la actualiza con la nueva distribución. Si no hay ninguna actividad activa, la selección queda guardada y se utilizará la próxima vez que pulses **Start**.

## Distribución predeterminada

### Compacta

- Izquierda: Batería
- Derecha: Estado térmico

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

El botón **Refresh** toma un nuevo snapshot y actualiza la Live Activity activa.

## Privacidad y compatibilidad con App Store

Islemetry utiliza intencionalmente frameworks públicos de Apple. La información de espacio en disco pertenece a las Required Reason APIs; el motivo aprobado por Apple `85F4.1` permite mostrar información de almacenamiento al usuario. UserDefaults se utiliza únicamente para guardar la configuración propia de Islemetry, correspondiente al motivo aprobado `CA92.1`.

El uptime del sistema se excluye intencionalmente de esta compilación orientada a App Store porque los motivos aprobados por Apple para la API de tiempo de arranque del sistema no incluyen simplemente mostrar el uptime del dispositivo como estadística de monitorización.
