import '../../battery/domain/models/battery_data.dart';
import '../../battery/domain/models/diagnostic_report.dart';
import '../domain/remote_telemetry_packet.dart';

class RemoteTelemetryMapper {
  const RemoteTelemetryMapper();

  RemoteTelemetryPacket fromBatteryData({
    required String sessionId,
    required BatteryData batteryData,
    required int sequenceNumber,
    DiagnosticReport? diagnosticReport,
  }) {
    return RemoteTelemetryPacket(
      sessionId: sessionId,
      timestamp: DateTime.now(),
      batteryData: batteryData,
      diagnosticReport: diagnosticReport,
      activeAlarms: batteryData.activeAlarms,
      sequenceNumber: sequenceNumber,
    );
  }

  Map<String, Object?> toOptimizedPayload(RemoteTelemetryPacket packet) {
    final battery = packet.batteryData;
    return {
      'sessionId': packet.sessionId,
      'timestamp': packet.timestamp.toIso8601String(),
      'sequenceNumber': packet.sequenceNumber,
      'battery': {
        'deviceId': battery.deviceId,
        'deviceName': battery.deviceName,
        'serialNumber': battery.serialNumber,
        'modelName': battery.modelName,
        'firmwareVersion': battery.firmwareVersion,
        'socPercent': battery.socPercent,
        'totalVoltage': battery.totalVoltage,
        'current': battery.current,
        'power': battery.power,
        'cycleCount': battery.cycleCount,
        'operationStatus': battery.operationStatus.name,
        'temperatures': [
          for (final sensor in battery.temperatures)
            {
              'id': sensor.id,
              'label': sensor.label,
              'celsius': sensor.celsius,
            },
        ],
        'cells': [
          for (final cell in battery.cells)
            {
              'index': cell.index,
              'voltage': cell.voltage,
              'isBalancing': cell.isBalancing,
              'status': cell.status.name,
            },
        ],
        'cellDeltaMv': battery.cellVoltageDelta * 1000,
        'chargeMosfetEnabled': battery.chargeMosfetEnabled,
        'dischargeMosfetEnabled': battery.dischargeMosfetEnabled,
        'isConnected': battery.isConnected,
        'rssi': battery.rssi,
      },
      'diagnosis': packet.diagnosticReport == null
          ? null
          : {
              'status': packet.diagnosticReport!.status.name,
              'summaryText': packet.diagnosticReport!.summaryText,
              'recommendations': packet.diagnosticReport!.recommendations,
            },
      'activeAlarms': [
        for (final alarm in packet.activeAlarms)
          {
            'code': alarm.code,
            'title': alarm.title,
            'severity': alarm.severity.name,
            'category': alarm.category.name,
            'recommendedAction': alarm.recommendedAction,
          },
      ],
    };
  }
}
