import 'alarm_data.dart';
import 'battery_data.dart';

enum DiagnosticStatus {
  ok,
  warning,
  critical,
  unknown,
}

class DiagnosticFinding {
  const DiagnosticFinding({
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendedAction,
  });

  final String title;
  final String description;
  final AlarmSeverity severity;
  final String recommendedAction;

  String get detail => description;
}

class DiagnosticReport {
  const DiagnosticReport({
    required this.reportId,
    required this.createdAt,
    required this.batteryData,
    required this.status,
    required this.findings,
    required this.recommendations,
    required this.summaryText,
    this.customerName,
    this.orderNumber,
    this.notes,
  });

  final String reportId;
  final DateTime createdAt;
  final BatteryData batteryData;
  final DiagnosticStatus status;
  final List<DiagnosticFinding> findings;
  final List<String> recommendations;
  final String summaryText;
  final String? customerName;
  final String? orderNumber;
  final String? notes;

  bool get isActionRequired {
    return status == DiagnosticStatus.warning ||
        status == DiagnosticStatus.critical;
  }
}

typedef DiagnosticSummary = DiagnosticReport;

