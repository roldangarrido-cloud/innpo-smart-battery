import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/local_storage.dart';
import '../domain/models/battery_data.dart';
import '../domain/models/history_sample.dart';

class BatteryHistoryRepository {
  BatteryHistoryRepository({
    Duration? sampleInterval,
  }) : sampleInterval = sampleInterval ?? const Duration(seconds: 30);

  final Duration sampleInterval;
  final _lastSavedAt = <String, DateTime>{};

  Future<void> recordIfDue(BatteryData data) async {
    if (!data.isConnected) {
      return;
    }
    final lastSavedAt = _lastSavedAt[data.deviceId];
    final now = DateTime.now();
    if (lastSavedAt != null && now.difference(lastSavedAt) < sampleInterval) {
      return;
    }
    _lastSavedAt[data.deviceId] = now;
    await save(BatteryHistorySample.fromBatteryData(data));
  }

  Future<void> save(BatteryHistorySample sample) async {
    final box = Hive.box<String>(LocalStorage.batteryHistoryBox);
    final key = '${sample.deviceId}_${sample.timestamp.toIso8601String()}';
    await box.put(key, sample.encode());
  }

  List<BatteryHistorySample> getSamples({
    required String deviceId,
    required HistoryRange range,
  }) {
    final box = Hive.box<String>(LocalStorage.batteryHistoryBox);
    final start = range.start(DateTime.now());
    final samples = box.values
        .map(BatteryHistorySample.decode)
        .where((sample) => sample.deviceId == deviceId)
        .where((sample) => start == null || !sample.timestamp.isBefore(start))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return samples;
  }

  Future<void> clearHistory({String? deviceId}) async {
    final box = Hive.box<String>(LocalStorage.batteryHistoryBox);
    if (deviceId == null) {
      _lastSavedAt.clear();
      await box.clear();
      return;
    }
    final keys = box.keys
        .whereType<String>()
        .where((key) => key.startsWith('${deviceId}_'))
        .toList();
    for (final key in keys) {
      await box.delete(key);
    }
    _lastSavedAt.remove(deviceId);
  }

  String buildCsv(List<BatteryHistorySample> samples) {
    final rows = [
      [
        'timestamp',
        'soc',
        'voltage',
        'current',
        'power',
        'temperature',
        'cycles',
        'alarms',
        'cell_delta_mv',
      ],
      for (final sample in samples)
        [
          sample.timestamp.toIso8601String(),
          sample.socPercent.toStringAsFixed(0),
          sample.totalVoltage.toStringAsFixed(2),
          sample.current.toStringAsFixed(1),
          sample.power.toStringAsFixed(0),
          sample.temperatureMax.toStringAsFixed(1),
          sample.cycleCount.toString(),
          sample.activeAlarmCount.toString(),
          (sample.cellVoltageDelta * 1000).round().toString(),
        ],
    ];
    return rows.map((row) => row.join(',')).join('\n');
  }
}
