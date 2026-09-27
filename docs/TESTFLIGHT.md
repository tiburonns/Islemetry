# Islemetry TestFlight preflight / Preflight de TestFlight

## English

Islemetry V0.4.2 (build 9) is a TestFlight candidate only after the protected branch passes the release-contract, core-test, Release Simulator, Release iPhoneOS, IPA, and AltStore validation gates.

### Physical gates

- Start/update/stop a Live Activity on a Dynamic Island device.
- Verify compact, expanded, and Lock Screen presentations.
- Verify foreground metric refresh and event-driven battery/network changes.
- Verify BGAppRefresh remains opportunistic rather than pretending to update every few seconds while suspended.
- Test optional background location permission, movement-driven updates, and the signed-out/denied-permission paths.
- Test English, Spanish, and System language modes in the app and Live Activity.
- Verify the WidgetKit extension installs and does not trigger SpringBoard launch errors.
- Run at least one 30-minute background/foreground cycle and inspect console logs for crashes.

### Archive

1. Pull protected `main` after CI is green.
2. Open `Islemetry.xcodeproj`.
3. Select the paid Apple Developer Team.
4. Confirm app and widget bundle identifiers.
5. Product > Archive.
6. Organizer > Validate App.
7. Upload to App Store Connect and begin with Internal Testing.

The source cannot certify iOS scheduling frequency. Background refresh remains controlled by iOS.

---

## Español

Islemetry V0.4.2 (build 9) sólo debe tratarse como candidato de TestFlight cuando la rama protegida pase contrato de release, tests, Release Simulator, Release iPhoneOS, IPA y validación AltStore.

### Gates físicos

- Iniciar/actualizar/detener Live Activity en un iPhone con Dynamic Island.
- Verificar vistas compacta, expandida y Lock Screen.
- Verificar refresh en foreground y cambios por eventos de batería/red.
- Confirmar que BGAppRefresh sigue siendo oportunista y no promete actualizaciones de segundos con la app suspendida.
- Probar permiso opcional de ubicación en segundo plano y rutas de permiso denegado.
- Probar Sistema, English y Español en app y Live Activity.
- Verificar instalación de la extensión WidgetKit sin errores de SpringBoard.
- Ejecutar al menos un ciclo de 30 minutos background/foreground revisando logs.

### Archive

1. Actualiza el `main` protegido cuando CI esté verde.
2. Abre `Islemetry.xcodeproj`.
3. Selecciona tu Team de pago.
4. Confirma bundle IDs de app y widget.
5. Product > Archive.
6. Organizer > Validate App.
7. Sube a App Store Connect y comienza con Internal Testing.

El código no puede certificar la frecuencia real del scheduler de iOS.
