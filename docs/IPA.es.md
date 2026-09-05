# Guía de IPA de Islemetry

**Español** · [English](IPA.md)

Esta guía explica qué es un archivo `.ipa` de Islemetry, cómo generarlo desde Xcode y cómo puede instalarse o distribuirse.

## ¿Qué es un IPA?

Un `.ipa` es un paquete de aplicación de iOS. Contiene Islemetry ya compilado y su extensión integrada, incluyendo `IslemetryWidgets`.

Clonar el código fuente no produce automáticamente un IPA. El archivo debe generarse a partir de un Archive correcto de Xcode y firmarse de acuerdo con el método de instalación o distribución previsto.

## Nota importante sobre la firma

El repositorio **no** contiene certificados privados, perfiles de aprovisionamiento, credenciales de Apple ni un IPA universal ya firmado.

Esto es intencional. El material de firma pertenece a cada cuenta y nunca debe almacenarse en el repositorio.

## Opción A — Instalar directamente desde Xcode

Para desarrollo y pruebas es la opción más sencilla y no requiere IPA:

1. Conecta el iPhone.
2. Selecciona el esquema `Islemetry`.
3. Selecciona el iPhone físico.
4. Configura la firma de ambos targets.
5. Presiona `⌘R`.

Xcode compila, firma, instala y abre Islemetry automáticamente.

## Opción B — Crear un IPA con Xcode Organizer

### 1. Selecciona un destino de iOS para distribución

En Xcode selecciona un destino genérico de iOS para Archive, no un simulador.

### 2. Crea el Archive

Selecciona:

```text
Product → Archive
```

Espera a que termine. Xcode debería abrir Organizer automáticamente.

### 3. Valida el Archive

En Organizer confirma que el Archive incluya la app Islemetry y la extensión `IslemetryWidgets`.

### 4. Distribuye

Selecciona:

```text
Distribute App
```

Xcode mostrará las opciones de distribución disponibles para tu cuenta de Apple Developer y la configuración actual del proyecto.

Elige el método adecuado para la instalación que deseas, completa la firma/aprovisionamiento y exporta el resultado.

Dependiendo del método elegido, Xcode puede generar un archivo `.ipa` junto con metadatos de distribución.

## Opción C — Crear el Archive desde Terminal

Usuarios avanzados pueden generar el Archive desde línea de comandos:

```bash
xcodebuild \
  -project Islemetry.xcodeproj \
  -scheme Islemetry \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$PWD/build/Islemetry.xcarchive" \
  archive
```

El Archive se guardará en:

```text
build/Islemetry.xcarchive
```

Para exportarlo como IPA se necesita un `ExportOptions.plist` válido que corresponda al método de firma/distribución de tu cuenta de Apple Developer.

Comando de ejemplo:

```bash
xcodebuild \
  -exportArchive \
  -archivePath "$PWD/build/Islemetry.xcarchive" \
  -exportPath "$PWD/build/export" \
  -exportOptionsPlist ExportOptions.plist
```

Como las opciones de exportación dependen de la cuenta y del método de distribución, Islemetry no almacena credenciales, certificados ni perfiles de firma específicos en el repositorio.

## Instalar un IPA exportado

La forma en la que puede instalarse depende de cómo fue firmado.

Flujos comunes de desarrollo/prueba incluyen:

- Instalación directa desde Xcode en un dispositivo registrado
- Distribución Development o Ad Hoc con el aprovisionamiento correspondiente
- TestFlight para distribución beta cuando se configure mediante App Store Connect
- Una herramienta de sideloading que vuelva a firmar la app usando el Apple ID o certificado del usuario

El método de firma determina qué dispositivos pueden abrir el IPA y la vigencia de su firma/aprovisionamiento.

## Publicar un IPA en GitHub Releases

Antes de adjuntar un IPA a una Release de GitHub:

1. Compila y prueba exactamente el commit que vas a publicar en un iPhone físico.
2. Verifica las vistas compacta, expandida y de pantalla bloqueada.
3. Confirma que el IPA incluya `IslemetryWidgets.appex`.
4. Confirma los bundle identifiers y los números de versión/build.
5. No publiques certificados privados, perfiles, contraseñas ni API keys.
6. Explica claramente qué método de firma usa el binario y quién puede instalarlo.

Nombre sugerido para el archivo:

```text
Islemetry-v0.2.0.ipa
```

Nombre sugerido para el código fuente:

```text
Islemetry-v0.2.0-source.zip
```

## Checklist de Release

```text
[ ] Commit de Release probado en iPhone físico
[ ] La app abre
[ ] La Live Activity inicia
[ ] Isla Dinámica compacta funciona
[ ] Isla Dinámica expandida funciona
[ ] Presentación de pantalla bloqueada funciona
[ ] Actualizar funciona
[ ] Detener funciona
[ ] Idioma Sistema / English / Español funciona
[ ] La selección de Isla Dinámica persiste
[ ] El icono de la app está incluido
[ ] Privacy manifest incluido
[ ] Número de versión/build correcto
[ ] No hay secretos de firma en el repositorio
[ ] IPA exportado correctamente
```

## Estado actual del repositorio

Actualmente el repositorio contiene el proyecto fuente y la documentación de desarrollo. Un IPA realmente distribuible debería publicarse únicamente después de validar la rama V0.2 actual en un iPhone y exportar un Archive de Release desde Xcode con la configuración de firma correspondiente.
