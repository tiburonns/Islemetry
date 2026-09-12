# Islemetry 0.2.1

Maintenance release focused on automatic telemetry updates and efficient Live Activity delivery.

## Changes

- Refreshes the in-app telemetry snapshot every three seconds while Islemetry is active.
- Refreshes immediately when the app returns to the foreground.
- Sends a Live Activity update only when its visible metric payload or configuration changes.
- Keeps event-driven refreshes for battery, power, thermal, brightness, and network changes.
- Cancels foreground sampling when iOS backgrounds or suspends the app.

## Distribution

- Version: `0.2.1`
- Build: `3`
- Minimum iOS: `17.0`
- AltStore Classic support remains available for community users.
