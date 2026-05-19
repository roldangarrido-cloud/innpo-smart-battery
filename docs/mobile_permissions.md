# Mobile Permissions

## User-facing copy

Bluetooth rationale:

> INNPO Smart Battery necesita acceso a Bluetooth para localizar y conectarse a tu bateria inteligente.

Android location rationale when required by OS restrictions:

> Algunas versiones de Android solicitan permiso de ubicacion para detectar dispositivos Bluetooth cercanos. INNPO Smart Battery no registra ni comparte tu ubicacion.

The Dart constants live in `lib/core/permissions/permissions_service.dart`.

## Android

When Flutter native folders exist, add these permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

If the real BLE implementation can assert that scan results are not derived for physical location on Android 12+, consider:

```xml
<uses-permission
    android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation" />
```

Storage permissions should not be requested by default. PDF/CSV reports should use app-scoped storage, `printing`, or `share_plus`. Add storage/media permissions only if a future export flow truly writes outside app-scoped or system-picker locations.

## iOS

When Flutter native folders exist, add usage strings to `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>INNPO Smart Battery necesita acceso a Bluetooth para localizar y conectarse a tu bateria inteligente.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>INNPO Smart Battery necesita acceso a Bluetooth para localizar y conectarse a tu bateria inteligente.</string>
```

File sharing through `share_plus`, `printing`, or the iOS share sheet normally does not require a custom runtime permission. Add document access capabilities only if a future workflow needs direct user document browsing.

