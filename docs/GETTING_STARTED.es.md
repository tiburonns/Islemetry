# Comenzar con Islemetry

**Español** · [English](GETTING_STARTED.md)

Esta guía explica cómo clonar Islemetry, abrirlo en Xcode, configurar la firma, compilarlo e instalarlo en un iPhone físico.

## Requisitos

- Una Mac compatible con una versión reciente de Xcode
- Xcode 26 o posterior recomendado
- iOS 17 o posterior en el iPhone de prueba
- Un Apple ID agregado a Xcode
- Un iPhone físico para validar completamente Live Activities e Isla Dinámica

No necesitas una membresía pagada del Apple Developer Program únicamente para abrir el proyecto o realizar desarrollo local normal. Algunos métodos de distribución sí pueden requerir certificados, perfiles de aprovisionamiento o una membresía pagada.

## 1. Clonar el repositorio

Desde Terminal:

```bash
git clone https://github.com/tiburonns/Islemetry.git
cd Islemetry
```

Actualmente el desarrollo activo se encuentra en:

```bash
git switch bootstrap/v0.1
```

Si esta rama ya fue fusionada con `main`, utiliza simplemente:

```bash
git switch main
```

Para actualizar una copia existente:

```bash
git fetch origin
git pull
```

## 2. Abrir el proyecto de Xcode

Desde Terminal:

```bash
open Islemetry.xcodeproj
```

También puedes abrir `Islemetry.xcodeproj` directamente desde Finder.

El proyecto contiene dos targets principales:

- `Islemetry` — la aplicación iOS
- `IslemetryWidgets` — la extensión WidgetKit / ActivityKit que renderiza la Live Activity y la Isla Dinámica

## 3. Configurar la firma

En Xcode:

1. Selecciona el proyecto **Islemetry** en el navegador.
2. Selecciona el target **Islemetry**.
3. Abre **Signing & Capabilities**.
4. Activa **Automatically manage signing**.
5. Selecciona tu equipo de Apple Developer.
6. Repite el proceso para **IslemetryWidgets**.

Los identificadores actuales son:

```text
com.tiburonns.islemetry
com.tiburonns.islemetry.widgets
```

Si Xcode indica que alguno no está disponible para tu cuenta, cámbialos por identificadores propios y únicos en ambos targets.

Ejemplo:

```text
com.tunombre.islemetry
com.tunombre.islemetry.widgets
```

Conviene mantener el identificador de la extensión relacionado con el de la app principal.

## 4. Seleccionar el iPhone

1. Conecta el iPhone a la Mac.
2. Confía en la Mac si iOS lo solicita.
3. Selecciona el iPhone físico como destino de ejecución en Xcode.
4. Activa Developer Mode en el iPhone si iOS lo solicita.

## 5. Compilar e instalar

En Xcode presiona:

```text
⌘R
```

o selecciona:

```text
Product → Run
```

Xcode debería compilar la app, integrar la extensión `IslemetryWidgets`, instalar Islemetry en el iPhone y abrirlo.

## 6. Primera prueba

Después de instalarlo:

1. Abre Islemetry.
2. Confirma que aparezcan las métricas del dispositivo.
3. Configura las métricas de la Isla Dinámica.
4. Elige **Sistema**, **English** o **Español** en Idioma.
5. Inicia la Live Activity.
6. Regresa a la pantalla de inicio.
7. Revisa la Isla Dinámica compacta.
8. Mantén presionada la Isla Dinámica para abrir la presentación expandida.
9. Bloquea el iPhone y revisa la Live Activity en la pantalla bloqueada.
10. Regresa a Islemetry y usa **Actualizar** para enviar un snapshot nuevo de telemetría.

La lista completa de validación está en [TESTING.es.md](TESTING.es.md).

## 7. Actualizar el proyecto posteriormente

Antes de descargar cambios nuevos, guarda con commit o stash cualquier modificación local.

Después:

```bash
git fetch origin
git pull
```

Si trabajas en la rama de desarrollo:

```bash
git switch bootstrap/v0.1
git pull origin bootstrap/v0.1
```

## Problemas comunes

### Error de firma

Confirma que ambos targets utilicen el mismo equipo de Apple Developer y que cada target tenga un identificador de bundle único.

### La extensión no se instala

Compila el target principal `Islemetry`, no la extensión por separado. La extensión se incluye dentro de la app durante la compilación normal.

### No aparece la Live Activity

Confirma que las Live Activities estén habilitadas para Islemetry en los ajustes de iOS y que estés probando en un dispositivo físico. La presentación en Isla Dinámica requiere además un modelo de iPhone con Isla Dinámica.

### La Isla Dinámica muestra valores anteriores

Abre Islemetry y usa **Actualizar**, o cambia la configuración y pulsa **Aplicar a Live Activity**. Muchas métricas son snapshots porque iOS no permite ejecutar Islemetry continuamente en segundo plano como un monitor de escritorio.

## Distribución mediante IPA

Ejecutar directamente desde Xcode no requiere un archivo `.ipa`. Si quieres un paquete distribuible, consulta [IPA.es.md](IPA.es.md).


## Ubicación y clima local

Islemetry puede mostrar el clima local utilizando la ubicación actual del iPhone.

La compilación predeterminada usa **Core Location + Open-Meteo**. No requiere entitlement de WeatherKit, lo que mantiene más simple la firma local con Personal Team y la distribución mediante AltStore.

### Primer flujo de permisos

1. Abre Islemetry en un iPhone físico.
2. Busca **Ubicación y clima** en la pantalla principal.
3. Pulsa **Permitir ubicación**.
4. Concede acceso a la ubicación cuando iOS lo solicite.
5. Pulsa **Actualizar clima** para pedir un nuevo snapshot meteorológico local.
6. Para permitir actualizaciones basadas en ubicación mientras Islemetry está en segundo plano, activa **Ubicación en segundo plano**.
7. iOS puede solicitar después permiso de ubicación **Siempre**. El momento exacto del aviso lo controla iOS.

El target principal declara las descripciones de privacidad para ubicación al usar la app y ubicación siempre, además del modo de segundo plano para ubicación. En Xcode, el target principal debe mostrar **Background Modes → Location updates** dentro de **Signing & Capabilities**.

### Comportamiento importante en segundo plano

La ubicación en segundo plano es opcional y se utiliza únicamente para la función de ubicación/clima. No se usa como mecanismo para mantener activo continuamente el muestreo arbitrario de CPU, RAM u otras métricas.

Cuando iOS entrega una actualización de ubicación en segundo plano, Islemetry puede actualizar el clima local y enviar un nuevo estado a una Live Activity activa. iOS sigue controlando cuándo y con qué frecuencia la app recibe tiempo de ejecución.

### Proveedor meteorológico

El clima actual se obtiene de **Open-Meteo**. La app muestra un enlace visible al proveedor junto a la información meteorológica. Se requiere conexión a Internet para obtener un dato nuevo.
