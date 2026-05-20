import 'dart:convert';

import 'battery_data.dart';

class BatteryHistorySample {
  const BatteryHistorySample({
    required this.deviceId,
    required this.timestamp,
    required this.socPercent,
    required this.totalVoltage,
    required this.current,
    required this.power,
    required this.temperatureMax,
    required this.cycleCount,
    required this.activeAlarmCount,
    required this.cellVoltageDelta,
  });

  final String deviceId;
  final DateTime timestamp;
  final double socPercent;
  final double totalVoltage;
  final double current;
  final double power;
  final double temperatureMax;
  final int cycleCount;
  final int activeAlarmCount;
  final double cellVoltageDelta;

  factory BatteryHistorySample.fromBatteryData(BatteryData data) {
    return BatteryHistorySample(
      deviceId: data.deviceId,
      timestamp: data.timestamp,
      socPercent: data.socPercent,
      totalVoltage: data.totalVoltage,
      current: data.current,
      power: data.power,
      temperatureMax: data.temperatureMax,
      cycleCount: data.cycleCount,
      activeAlarmCount: data.activeAlarms.length,
      cellVoltageDelta: data.cellVoltageDelta,
    );
  }

  factory BatteryHistorySample.fromJson(Map<String, dynamic> json) {
    return BatteryHistorySample(
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      socPercent: (json['socPercent'] as num).toDouble(),
      totalVoltage: (json['totalVoltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      power: (json['power'] as num).toDouble(),
      temperatureMax: (json['temperatureMax'] as num).toDouble(),
      cycleCount: json['cycleCount'] as int,
      activeAlarmCount: json['activeAlarmCount'] as int,
      cellVoltageDelta: (json['cellVoltageDelta'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'socPercent': socPercent,
      'totalVoltage': totalVoltage,
      'current': current,
      'power': power,
      'temperatureMax': temperatureMax,
      'cycleCount': cycleCount,
      'activeAlarmCount': activeAlarmCount,
      'cellVoltageDelta': cellVoltageDelta,
    };
  }

  String encode() => jsonEncode(toJson());

  static BatteryHistorySample decode(String value) {
    return BatteryHistorySample.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}

enum HistoryRange {
  lastHour,
  today,
  sevenDays,
  thirtyDays,
  all,
}

extension HistoryRangeLabel on HistoryRange {
  String get label {
    return switch (this) {
      HistoryRange.lastHour => 'Ultima hora',
      HistoryRange.today => 'Hoy',
      HistoryRange.sevenDays => '7 dias',
      HistoryRange.thirtyDays => '30 dias',
      HistoryRange.all => 'Todo',
    };
  }

  DateTime? start(DateTime now) {
    return switch (this) {
      HistoryRange.lastHour => now.subtract(const Duration(hours: 1)),
      HistoryRange.today => DateTime(now.year, now.month, now.day),
      HistoryRange.sevenDays => now.subtract(const Duration(days: 7)),
      HistoryRange.thirtyDays => now.subtract(const Duration(days: 30)),
      HistoryRange.all => null,
    };
  }
}

