import '../../../core/errors/ble_error.dart';
import '../../../core/logging/local_event_log.dart';
import '../../../core/permissions/permissions_service.dart';
import '../domain/ble_device.dart';
import '../domain/ble_repository.dart';

class BleScannerService {
  BleScannerService({
    required BleRepository repository,
    required PermissionsService permissionsService,
  })  : _repository = repository,
        _permissionsService = permissionsService;

  final BleRepository _repository;
  final PermissionsService _permissionsService;

  Future<Stream<List<BleDevice>>> scanCompatibleDevices() {
    return scanDevices(onlyCompatible: true);
  }

  Future<Stream<List<BleDevice>>> scanDevices({
    bool onlyCompatible = false,
  }) async {
    final permissionResult = await _permissionsService.requestBlePermissions();
    if (!permissionResult.granted) {
      await LocalEventLogRepository().record(
        type: AppLogEventType.bleError,
        message: permissionResult.userMessage ??
            PermissionRequestCopy.bluetoothRationale,
      );
      throw BleError(
        permissionResult.userMessage ??
            PermissionRequestCopy.bluetoothRationale,
        code: 'ble-permission-denied',
      );
    }

    return _repository.scanForBatteries().map((devices) {
      if (!onlyCompatible) {
        return devices;
      }
      return devices
          .where((device) => device.isInnpoCandidate)
          .toList(growable: false);
    });
  }

  Future<void> stopScan() => _repository.stopScan();
}
