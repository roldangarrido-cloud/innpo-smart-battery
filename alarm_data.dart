enum AlarmSeverity {
  info,
  warning,
  critical,
}

enum AlarmCategory {
  voltage,
  current,
  temperature,
  communication,
  balancing,
  mosfet,
  hardware,
  unknown,
}

class AlarmData {
  const AlarmData({
    required this.code,
    required this.title,
    required this.technicalDescription,
    required this.userFriendlyDescription,
    required this.severity,
    required this.recommendedAction,
    required this.timestamp,
    required this.isActive,
    this.category = AlarmCategory.unknown,
  });

  final String code;
  final String title;
  final String technicalDescription;
  final String userFriendlyDescription;
  final AlarmSeverity severity;
  final String recommendedAction;
  final DateTime timestamp;
  final bool isActive;
  final AlarmCategory category;

  String get description => userFriendlyDescription;
  bool get active => isActive;
}

typedef BmsAlarm = AlarmData;

