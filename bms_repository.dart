import 'models/battery_data.dart';

abstract interface class BmsRepository {
  Future<void> connect(String deviceId);
  Future<void> disconnect(String deviceId);
  Future<void> reconnect(String deviceId);
  Stream<BatteryData> watchBatteryData(String deviceId);
  Future<BatteryData> readBatteryData(String deviceId);
  Future<void> writeConfigurationCommand({
    required String deviceId,
    required List<int> command,
  });
}
