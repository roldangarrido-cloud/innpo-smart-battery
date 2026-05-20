import '../../battery/domain/models/battery_data.dart';
import 'ble_connection_state.dart';

abstract interface class BleRepository {
  Stream<List<BleBatteryDevice>> scanForBatteries();
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect(String deviceId);
  Future<void> discoverServices(String deviceId);
  Stream<BleConnectionState> connectionStates(String deviceId);
  Stream<List<int>> notifications(String deviceId);
  Future<List<int>> read(String deviceId, String characteristicUuid);
  Future<void> write(
    String deviceId,
    String characteristicUuid,
    List<int> payload,
  );
}
