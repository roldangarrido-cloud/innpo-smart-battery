import '../models/battery_data.dart';

class BatteryAlarmInterpreter {
  const BatteryAlarmInterpreter();

  String actionFor(AlarmData alarm) {
    return switch (alarm.severity) {
      AlarmSeverity.info => 'Revisar informacion.',
      AlarmSeverity.warning => 'Supervisar y generar informe si persiste.',
      AlarmSeverity.critical => 'Detener uso y contactar con soporte.',
    };
  }
}
