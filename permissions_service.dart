import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionRequestCopy {
  const PermissionRequestCopy._();

  static const bluetoothRationale =
      'INNPO Smart Battery necesita acceso a Bluetooth para localizar y conectarse a tu bateria inteligente.';

  static const androidLocationRationale =
      'Algunas versiones de Android solicitan permiso de ubicacion para detectar dispositivos Bluetooth cercanos. INNPO Smart Battery no registra ni comparte tu ubicacion.';
}

class BlePermissionResult {
  const BlePermissionResult({
    required this.granted,
    required this.requestedPermissions,
    this.deniedPermission,
    this.userMessage,
  });

  final bool granted;
  final List<Permission> requestedPermissions;
  final Permission? deniedPermission;
  final String? userMessage;
}

class PermissionsService {
  Future<BlePermissionResult> requestBlePermissions() async {
    final permissions = _blePermissionsForPlatform();
    if (permissions.isEmpty) {
      return const BlePermissionResult(
        granted: true,
        requestedPermissions: [],
      );
    }

    final statuses = await permissions.request();
    for (final permission in permissions) {
      final status = statuses[permission];
      if (status == null || !status.isGranted) {
        return BlePermissionResult(
          granted: false,
          requestedPermissions: permissions,
          deniedPermission: permission,
          userMessage: _messageFor(permission),
        );
      }
    }

    return BlePermissionResult(
      granted: true,
      requestedPermissions: permissions,
    );
  }

  Future<bool> ensureBlePermissions() async {
    final result = await requestBlePermissions();
    return result.granted;
  }

  Future<bool> openAppPermissionSettings() {
    return openAppSettings();
  }

  List<Permission> _blePermissionsForPlatform() {
    if (Platform.isAndroid) {
      return const [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];
    }

    if (Platform.isIOS) {
      return const [
        Permission.bluetooth,
      ];
    }

    return const [];
  }

  String _messageFor(Permission permission) {
    if (permission == Permission.locationWhenInUse) {
      return PermissionRequestCopy.androidLocationRationale;
    }
    return PermissionRequestCopy.bluetoothRationale;
  }
}

