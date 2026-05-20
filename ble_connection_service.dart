import 'dart:async';

import '../../../core/errors/ble_error.dart';
import '../../../core/logging/local_event_log.dart';
import '../domain/ble_connection_state.dart';
import '../domain/ble_repository.dart';

class BleConnectionService {
  const BleConnectionService({
    required BleRepository repository,
    this.operationTimeout = const Duration(seconds: 10),
  }) : _repository = repository;

  final BleRepository _repository;
  final Duration operationTimeout;

  Stream<BleConnectionState> states(String deviceId) {
    return _repository.connectionStates(deviceId);
  }

  Future<void> connect(String deviceId) async {
    try {
      await _repository.connect(deviceId).timeout(operationTimeout);
      await LocalEventLogRepository().record(
        type: AppLogEventType.connection,
        message: 'Conexión BLE establecida.',
        deviceId: deviceId,
      );
      await discoverServices(deviceId);
    } on TimeoutException catch (_) {
      await LocalEventLogRepository().record(
        type: AppLogEventType.bleError,
        message: 'Timeout de conexión BLE.',
        deviceId: deviceId,
      );
      throw const BleError('Connection timeout.', code: 'ble-timeout');
    } catch (error) {
      await LocalEventLogRepository().record(
        type: AppLogEventType.bleError,
        message: error.toString(),
        deviceId: deviceId,
      );
      rethrow;
    }
  }

  Future<void> disconnect(String deviceId) async {
    await _repository.disconnect(deviceId);
    await LocalEventLogRepository().record(
      type: AppLogEventType.disconnection,
      message: 'Dispositivo BLE desconectado.',
      deviceId: deviceId,
    );
  }

  Future<void> reconnect(String deviceId) async {
    await disconnect(deviceId);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await connect(deviceId);
  }

  StreamSubscription<BleConnectionState> enableAutoReconnect(String deviceId) {
    return states(deviceId).listen((state) {
      if (state.status == BleConnectionStatus.disconnected) {
        unawaited(reconnect(deviceId));
      }
    });
  }

  Future<void> discoverServices(String deviceId) {
    return _repository.discoverServices(deviceId).timeout(operationTimeout);
  }

  Stream<List<int>> subscribeToNotifications(String deviceId) {
    return _repository.notifications(deviceId);
  }

  Future<void> writeCommand({
    required String deviceId,
    required String characteristicUuid,
    required List<int> payload,
  }) {
    return _repository
        .write(deviceId, characteristicUuid, payload)
        .timeout(operationTimeout);
  }

  Future<List<int>> readCharacteristic({
    required String deviceId,
    required String characteristicUuid,
  }) {
    return _repository
        .read(deviceId, characteristicUuid)
        .timeout(operationTimeout);
  }
}
