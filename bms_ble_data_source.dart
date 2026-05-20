import '../../../core/constants/ble_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/logging/local_event_log.dart';
import '../../bluetooth/data/ble_connection_service.dart';
import '../../bluetooth/data/ble_scanner_service.dart';
import '../../bluetooth/domain/ble_device.dart';
import '../domain/bms_repository.dart';
import '../domain/models/battery_data.dart';
import 'bms_parser.dart';

class BmsBleDataSource {
  const BmsBleDataSource({
    required BleConnectionService connectionService,
    required BmsParser parser,
    this.config = mockBmsProtocolConfig,
    this.allowConfigurationWrites = !AppConstants.safeReadOnlyModeDefault,
  })  : _connectionService = connectionService,
        _parser = parser;

  final BleConnectionService _connectionService;
  final BmsParser _parser;
  final BmsProtocolConfig config;
  final bool allowConfigurationWrites;

  /// Sends a command through the BLE write characteristic.
  ///
  /// Configuration writes are disabled by default so the MVP is read-only
  /// until the real BMS protocol and safety process are validated.
  Future<void> sendCommand({
    required String deviceId,
    required List<int> command,
    bool configurationWrite = false,
  }) {
    if (configurationWrite && !allowConfigurationWrites) {
      throw const AppError(
        'La app está en modo seguro de solo lectura.',
        code: 'read-only-mode',
      );
    }
    return _connectionService.writeCommand(
      deviceId: deviceId,
      characteristicUuid: config.writeCharacteristicUuid,
      payload: command,
    );
  }

  Future<List<int>> readBytes(String deviceId) {
    return _connectionService.readCharacteristic(
      deviceId: deviceId,
      characteristicUuid: config.readCharacteristicUuid,
    );
  }

  Future<BatteryData> readBatteryData(String deviceId) async {
    await sendCommand(
      deviceId: deviceId,
      command: _parser.buildReadStatusCommand(),
    );
    final frame = await readBytes(deviceId);
    return _parser.parseBatteryStatus(frame);
  }

  Stream<BatteryData> watchBatteryData(String deviceId) async* {
    yield await readBatteryData(deviceId);
    await for (final frame in _connectionService.subscribeToNotifications(deviceId)) {
      yield _parser.parseBatteryStatus(frame);
    }
  }
}

abstract interface class BatteryRepository {
  Stream<List<BleDevice>> scan();
  Future<void> connect(String deviceId);
  Stream<BatteryData> watchStatus(String deviceId);
}

class BleBatteryRepository implements BatteryRepository, BmsRepository {
  BleBatteryRepository({
    required BleScannerService scannerService,
    required BleConnectionService connectionService,
    required BmsBleDataSource dataSource,
  })  : _scannerService = scannerService,
        _connectionService = connectionService,
        _dataSource = dataSource;

  final BleScannerService _scannerService;
  final BleConnectionService _connectionService;
  final BmsBleDataSource _dataSource;

  @override
  Stream<List<BleDevice>> scan() async* {
    final stream = await _scannerService.scanCompatibleDevices();
    yield* stream;
  }

  @override
  Future<void> connect(String deviceId) => _connectionService.connect(deviceId);

  @override
  Future<void> disconnect(String deviceId) {
    return _connectionService.disconnect(deviceId);
  }

  @override
  Future<void> reconnect(String deviceId) {
    return _connectionService.reconnect(deviceId);
  }

  @override
  Stream<BatteryData> watchStatus(String deviceId) {
    return watchBatteryData(deviceId);
  }

  @override
  Stream<BatteryData> watchBatteryData(String deviceId) {
    return _dataSource.watchBatteryData(deviceId);
  }

  @override
  Future<BatteryData> readBatteryData(String deviceId) {
    return _dataSource.readBatteryData(deviceId);
  }

  @override
  Future<void> writeConfigurationCommand({
    required String deviceId,
    required List<int> command,
  }) {
    return _dataSource
        .sendCommand(
          deviceId: deviceId,
          command: command,
          configurationWrite: true,
        )
        .then((_) => LocalEventLogRepository().record(
              type: AppLogEventType.configurationChange,
              message: 'Comando de configuración enviado al BMS.',
              deviceId: deviceId,
            ));
  }
}
