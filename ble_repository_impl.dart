import 'dart:async';

import '../../battery/domain/models/battery_data.dart';
import '../domain/ble_connection_state.dart';
import '../domain/ble_repository.dart';

class BleRepositoryImpl implements BleRepository {
  final _connectionControllers = <String, StreamController<BleConnectionState>>{};

  @override
  Stream<List<BleBatteryDevice>> scanForBatteries() async* {
    yield const [
      BleBatteryDevice(
        id: 'mock-12v-100ah',
        name: 'INNPO LiFePO4 12.8V 100Ah',
        rssi: -48,
        isInnpoCandidate: true,
        batteryModel: 'INNPO-LFP-12.8V-100Ah',
        serialNumber: 'INNPO-12V-MOCK-001',
      ),
      BleBatteryDevice(
        id: 'mock-24v-100ah',
        name: 'INNPO LiFePO4 25.6V 100Ah',
        rssi: -56,
        isInnpoCandidate: true,
        batteryModel: 'INNPO-LFP-25.6V-100Ah',
        serialNumber: 'INNPO-24V-MOCK-001',
      ),
      BleBatteryDevice(
        id: 'mock-golf-51v-100ah',
        name: 'INNPO Golf Battery 51.2V 100Ah',
        rssi: -63,
        isInnpoCandidate: true,
        batteryModel: 'INNPO-GOLF-51.2V-100Ah',
        serialNumber: 'INNPO-GOLF-MOCK-001',
      ),
      BleBatteryDevice(
        id: 'unknown-ble-device',
        name: 'BLE Device',
        rssi: -78,
        isInnpoCandidate: false,
      ),
    ];
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String deviceId) async {
    _emit(deviceId, BleConnectionStatus.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _emit(deviceId, BleConnectionStatus.connected);
  }

  @override
  Future<void> disconnect(String deviceId) async {
    _emit(deviceId, BleConnectionStatus.disconnected);
  }

  @override
  Future<void> discoverServices(String deviceId) async {
    _emit(deviceId, BleConnectionStatus.discoveringServices);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _emit(deviceId, BleConnectionStatus.connected);
  }

  @override
  Stream<BleConnectionState> connectionStates(String deviceId) {
    return _controllerFor(deviceId).stream;
  }

  @override
  Stream<List<int>> notifications(String deviceId) async* {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      yield const [0x49, 0x4E, 0x4E, 0x50, 0x4F];
    }
  }

  @override
  Future<List<int>> read(String deviceId, String characteristicUuid) async {
    return const [0x49, 0x4E, 0x4E, 0x50, 0x4F];
  }

  @override
  Future<void> write(
    String deviceId,
    String characteristicUuid,
    List<int> payload,
  ) async {}

  StreamController<BleConnectionState> _controllerFor(String deviceId) {
    return _connectionControllers.putIfAbsent(
      deviceId,
      () => StreamController<BleConnectionState>.broadcast(),
    );
  }

  void _emit(String deviceId, BleConnectionStatus status, {String? error}) {
    _controllerFor(deviceId).add(
      BleConnectionState(
        status: status,
        deviceId: deviceId,
        errorMessage: error,
      ),
    );
  }
}
