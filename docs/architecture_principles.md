# INNPO Smart Battery - Architecture Principles

## Offline-first

The app must work without internet for the core battery workflow:

- BLE scan and connection.
- Battery status reading.
- Cell voltage view.
- BMS alarms view.
- Local diagnostic engine.
- Local help articles.
- Local PDF report generation.

Internet must never be required for basic monitoring or diagnostics.

## Optional internet

Network access is reserved for optional workflows:

- Send diagnostics to INNPO support.
- Register warranty.
- Future cloud history sync.
- Future firmware update, only if the BMS supports it safely.
- Online documentation.

These features should live behind integration ports, not inside the BLE, domain or UI core.

## No mandatory account

The customer can use the app without registration. Any identity, warranty or cloud account flow must be optional and additive.

## Customer mode and technician mode

Customer mode prioritizes readable status, clear warnings and recommended actions.

Technician mode exposes advanced data, logs, export options and protected actions. Dangerous operations must remain locked behind technician PIN and real BMS protocol capability checks.

## Protected actions

The following actions require technician PIN:

- Modify BMS parameters.
- Enable or disable MOSFET.
- Change nominal capacity.
- Calibrate voltage or current.
- Restore configuration.
- Import profiles.

The UI can expose these actions only as protected commands. The protocol implementation must also validate whether each command is supported by the connected BMS.

## Scalable boundaries

Future systems must be added through ports/adapters:

- Cloud.
- Web panel.
- Fleet management.
- Warranty registration.
- Zendesk, Holded, PrestaShop or ERP integrations.

Initial ports are declared in `lib/core/integrations/external_integrations.dart`.

