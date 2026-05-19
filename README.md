# INNPO Smart Battery

## Descripción

App móvil Flutter para monitorización y diagnóstico de baterías inteligentes INNPO mediante Bluetooth Low Energy.

La app está preparada para funcionar en modo demo mientras se recibe el protocolo BLE real del fabricante del BMS.

## Funcionalidades

- Monitorización de batería.
- Lectura BLE.
- Modo demo.
- Diagnóstico.
- Informes PDF.
- Histórico.
- Modo técnico.

## Stack

- Flutter
- Dart
- Riverpod
- flutter_blue_plus
- Hive/Isar
- fl_chart
- pdf
- intl

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

Para ejecutar tests:

```bash
flutter test
```

## Modo demo

El modo demo permite usar la app sin batería física.

Para activarlo:

1. Abrir la app.
2. Ir a la pantalla **Buscar batería**.
3. Pulsar **Modo demo**.
4. Seleccionar un caso demo, por ejemplo:
   - Batería correcta 12.8V 100Ah.
   - Batería correcta 25.6V 100Ah.
   - Batería golf 51.2V 100Ah.
   - Baja temperatura.
   - Sobrecorriente.
   - Celdas desequilibradas.
5. Entrar en el dashboard.

En modo demo se puede navegar por Estado, Celdas, Histórico, Diagnóstico, Ajustes, Alarmas e Informe PDF.

## Integración BLE real

Actualmente la app usa `MockBmsParser` para simular datos del BMS.

Cuando el fabricante entregue el protocolo real, se debe sustituir `MockBmsParser` por un parser real que implemente `BmsParser`.

También se deberán actualizar:

- Service UUID.
- Read characteristic UUID.
- Write characteristic UUID.
- Notify characteristic UUID.
- Comandos BLE.
- Estructura de tramas.
- Checksum.
- Códigos de alarma.
- Parámetros configurables.
- Autenticación/PIN del BMS si existe.

La UI está desacoplada del protocolo BLE. El cambio principal debe concentrarse en:

- `lib/features/battery/data/bms_parser.dart`
- `lib/features/battery/data/bms_ble_data_source.dart`
- `lib/features/bluetooth/data/ble_connection_service.dart`
- `lib/core/constants/ble_constants.dart`

## Estructura de carpetas

La app sigue una arquitectura por capas:

```text
lib/
  app/          Configuración global, rutas, tema e internacionalización.
  core/         Constantes, errores, permisos, seguridad, logging y utilidades.
  features/    Funcionalidades principales separadas por dominio.
  shared/      Widgets reutilizables.
```

Features principales:

```text
features/
  bluetooth/   Escaneo, conexión y servicios BLE.
  battery/     Modelos, parser BMS, diagnóstico, histórico y UI de batería.
  reports/     Generación y vista previa de informes PDF.
  support/     Soporte INNPO, garantía, ayuda y contacto.
  settings/    Ajustes de app, modo cliente/técnico y preferencias locales.
```

Principios:

- UI separada de BLE.
- Parser BMS reemplazable.
- Offline-first.
- Sin registro obligatorio.
- Modo seguro de solo lectura por defecto.
- Modo técnico protegido por PIN.

## Próximos pasos

- Integrar protocolo BLE real.
- Añadir cloud opcional.
- Añadir registro de garantía.
- Añadir panel soporte.

