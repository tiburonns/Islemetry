#!/usr/bin/env bash
# Build an unsigned physical-device IPA that AltStore Classic can re-sign.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-$ROOT_DIR/dist}"
DERIVED_DATA="$(mktemp -d "${TMPDIR:-/tmp}/Islemetry-AltStore-DerivedData.XXXXXX")"
PACKAGE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/Islemetry-AltStore-Package.XXXXXX")"

cleanup() {
  case "$DERIVED_DATA" in
    "${TMPDIR:-/tmp}"/Islemetry-AltStore-DerivedData.*) /bin/rm -rf -- "$DERIVED_DATA" ;;
  esac
  case "$PACKAGE_ROOT" in
    "${TMPDIR:-/tmp}"/Islemetry-AltStore-Package.*) /bin/rm -rf -- "$PACKAGE_ROOT" ;;
  esac
}
trap cleanup EXIT

xcodebuild \
  -project "$ROOT_DIR/Islemetry.xcodeproj" \
  -scheme Islemetry \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY= \
  DEVELOPMENT_TEAM= \
  build

APP_BUNDLE="$DERIVED_DATA/Build/Products/Release-iphoneos/Islemetry.app"
INFO_PLIST="$APP_BUNDLE/Info.plist"
WIDGET_BUNDLE="$APP_BUNDLE/PlugIns/IslemetryWidgets.appex"

test -d "$APP_BUNDLE"
test -f "$INFO_PLIST"
test -d "$WIDGET_BUNDLE"
test -f "$APP_BUNDLE/PrivacyInfo.xcprivacy"
test -f "$APP_BUNDLE/Assets.car"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
BUILD_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$INFO_PLIST")"
MAIN_EXECUTABLE="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$INFO_PLIST")"
WIDGET_EXECUTABLE="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$WIDGET_BUNDLE/Info.plist")"

[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "Versión inválida: $VERSION" >&2
  exit 1
}

if find "$APP_BUNDLE" \( -name '_CodeSignature' -o -name 'embedded.mobileprovision' \) -print -quit | grep -q .; then
  echo "La aplicación contiene una firma o perfil y no se publicará." >&2
  exit 1
fi

MAIN_ARCHITECTURES="$(lipo -archs "$APP_BUNDLE/$MAIN_EXECUTABLE")"
WIDGET_ARCHITECTURES="$(lipo -archs "$WIDGET_BUNDLE/$WIDGET_EXECUTABLE")"
[[ " $MAIN_ARCHITECTURES " == *" arm64 "* ]]
[[ " $WIDGET_ARCHITECTURES " == *" arm64 "* ]]

mkdir -p "$PACKAGE_ROOT/Payload" "$OUTPUT_DIR"
/usr/bin/ditto "$APP_BUNDLE" "$PACKAGE_ROOT/Payload/Islemetry.app"

OUTPUT_FILE="$OUTPUT_DIR/Islemetry-$VERSION.ipa"
if [[ -e "$OUTPUT_FILE" ]]; then
  echo "El archivo ya existe; muévelo o elimínalo antes de repetir: $OUTPUT_FILE" >&2
  exit 1
fi

(
  cd "$PACKAGE_ROOT"
  COPYFILE_DISABLE=1 /usr/bin/zip -qry "$OUTPUT_FILE" Payload
)

/usr/bin/unzip -tq "$OUTPUT_FILE"
if unzip -Z1 "$OUTPUT_FILE" | grep -Eq '_CodeSignature|embedded\.mobileprovision|^__MACOSX/'; then
  echo "La validación encontró contenido no permitido en la IPA." >&2
  exit 1
fi

echo "IPA compatible con AltStore creada correctamente."
echo "Versión: $VERSION ($BUILD_VERSION)"
echo "Arquitecturas: app=$MAIN_ARCHITECTURES widget=$WIDGET_ARCHITECTURES"
echo "Archivo: $OUTPUT_FILE"
shasum -a 256 "$OUTPUT_FILE"
