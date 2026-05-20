import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const reportsBox = 'diagnostic_reports';
  static const batteryHistoryBox = 'battery_history';
  static const knownBatteriesBox = 'known_batteries';
  static const diagnosticsBox = 'diagnostics_history';
  static const eventLogsBox = 'event_logs';
  static const appPreferencesBox = 'app_preferences';
  static const reportMetadataBox = 'report_metadata';
  static const lastConnectedDeviceIdKey = 'last_connected_device_id';
  static const lastConnectedDeviceNameKey = 'last_connected_device_name';
  static const settingsKey = 'settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(reportsBox);
    await Hive.openBox<String>(batteryHistoryBox);
    await Hive.openBox<String>(knownBatteriesBox);
    await Hive.openBox<String>(diagnosticsBox);
    await Hive.openBox<String>(eventLogsBox);
    await Hive.openBox<String>(appPreferencesBox);
    await Hive.openBox<String>(reportMetadataBox);
  }
}
