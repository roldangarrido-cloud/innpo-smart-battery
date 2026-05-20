import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../storage/local_storage.dart';
import 'app_logger.dart';

enum AppLogEventType {
  connection,
  disconnection,
  configurationChange,
  bleError,
  alarmDetected,
  security,
}

class AppLogEvent {
  const AppLogEvent({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.deviceId,
    this.details = const {},
  });

  final String id;
  final AppLogEventType type;
  final String message;
  final DateTime timestamp;
  final String? deviceId;
  final Map<String, Object?> details;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'details': details,
    };
  }

  factory AppLogEvent.fromJson(Map<String, dynamic> json) {
    return AppLogEvent(
      id: json['id'] as String,
      type: AppLogEventType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AppLogEventType.security,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceId: json['deviceId'] as String?,
      details: (json['details'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}

class LocalEventLogRepository {
  Box<String> get _box => Hive.box<String>(LocalStorage.eventLogsBox);

  Future<void> record({
    required AppLogEventType type,
    required String message,
    String? deviceId,
    Map<String, Object?> details = const {},
  }) async {
    final event = AppLogEvent(
      id: 'log-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      message: message,
      timestamp: DateTime.now(),
      deviceId: deviceId,
      details: details,
    );
    await _box.put(event.id, jsonEncode(event.toJson()));
    appLogger.i('${type.name}: $message');
  }

  List<AppLogEvent> getAll() {
    return _box.values
        .map((raw) => AppLogEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> clear() => _box.clear();
}

