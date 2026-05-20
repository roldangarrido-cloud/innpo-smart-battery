import '../models/battery_data.dart';
import '../models/battery_profile.dart';
import '../models/diagnostic_report.dart';

class BatteryDiagnosticService {
  const BatteryDiagnosticService({
    BatteryProfile? defaultProfile,
  }) : defaultProfile = defaultProfile ?? defaultDiagnosticProfile;

  static const defaultDiagnosticProfile = BatteryProfile(
    id: 'generic-bms',
    name: 'Generic BMS',
    chemistry: BatteryChemistry.unknown,
    seriesCellCount: 4,
    nominalVoltage: 12.8,
    nominalCapacityAh: 100,
    minCellVoltage: 2.5,
    maxCellVoltage: 3.65,
    recommendedChargeVoltage: 14.6,
    maxChargeCurrent: 50,
    maxDischargeCurrent: 100,
    minChargeTemperature: 0,
    maxChargeTemperature: 45,
    minDischargeTemperature: -20,
    maxDischargeTemperature: 60,
    cellDeltaOkThresholdMv: 20,
    cellDeltaWarningThresholdMv: 50,
    cellDeltaCriticalThresholdMv: 100,
    expectedCycleLife: 2000,
  );

  final BatteryProfile defaultProfile;

  DiagnosticReport evaluate(
    BatteryData? data, {
    BatteryProfile? profile,
  }) {
    if (!_hasEnoughData(data)) {
      return _unknownReport();
    }

    final battery = data!;
    final effectiveProfile = profile ??
        (battery.nominalCapacityAh > 0
            ? BatteryProfile.fromBatteryData(battery)
            : defaultProfile);
    final findings = <DiagnosticFinding>[];
    final primary = _primaryFinding(battery, effectiveProfile);

    findings.add(primary.finding);
    findings.addAll(_alarmFindings(battery, skipCoveredBy: primary.rule));

    final status = _statusFor(findings);
    return DiagnosticReport(
      reportId: 'diag-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      batteryData: battery,
      status: status,
      findings: findings,
      recommendations: [
        for (final finding in findings) finding.recommendedAction,
      ],
      summaryText: primary.message,
    );
  }

  bool _hasEnoughData(BatteryData? data) {
    if (data == null || !data.isConnected) {
      return false;
    }
    return data.cells.isNotEmpty && data.temperatures.isNotEmpty;
  }

  _DiagnosticRuleResult _primaryFinding(
    BatteryData battery,
    BatteryProfile profile,
  ) {
    if (_isLowTemperatureChargeBlocked(battery, profile)) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.lowTemperatureCharge,
        message:
            'La carga está bloqueada por baja temperatura. No cargue la batería hasta que alcance una temperatura segura.',
        finding: const DiagnosticFinding(
          title: 'Carga bloqueada por baja temperatura',
          description:
              'El BMS ha detenido la carga porque la batería está por debajo de la temperatura segura de carga.',
          severity: AlarmSeverity.critical,
          recommendedAction:
              'Espere a que la batería alcance una temperatura adecuada antes de cargarla. No fuerce la carga en frío.',
        ),
      );
    }

    if (_hasHighTemperature(battery, profile)) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.highTemperature,
        message:
            'Temperatura elevada. Detenga el uso y espere a que la batería se enfríe.',
        finding: DiagnosticFinding(
          title: 'Temperatura elevada',
          description:
              'Temperatura máxima detectada: ${battery.temperatureMax.toStringAsFixed(1)} C.',
          severity: AlarmSeverity.critical,
          recommendedAction:
              'Detenga carga o descarga, mejore la ventilación y espere a que la batería se enfríe.',
        ),
      );
    }

    if (_hasOverCurrent(battery, profile)) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.overCurrent,
        message:
            'El BMS ha detectado una corriente superior al límite permitido. Revise la instalación o el consumo conectado.',
        finding: DiagnosticFinding(
          title: 'Sobrecorriente',
          description:
              'Corriente detectada: ${battery.current.toStringAsFixed(1)} A.',
          severity: AlarmSeverity.critical,
          recommendedAction:
              'Reduzca el consumo conectado y revise cableado, fusibles, inversor o cargador.',
        ),
      );
    }

    if (!battery.chargeMosfetEnabled || !battery.dischargeMosfetEnabled) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.mosfetBlocked,
        message: !battery.chargeMosfetEnabled
            ? 'Carga bloqueada.'
            : 'Descarga bloqueada.',
        finding: DiagnosticFinding(
          title: !battery.chargeMosfetEnabled
              ? 'Carga bloqueada'
              : 'Descarga bloqueada',
          description:
              'El BMS mantiene deshabilitado uno de los MOSFET de protección.',
          severity: AlarmSeverity.critical,
          recommendedAction:
              'Revise alarmas activas y no fuerce el uso hasta resolver la causa.',
        ),
      );
    }

    final cellDeltaMv = battery.cellVoltageDelta * 1000;
    if (cellDeltaMv > profile.cellDeltaCriticalThresholdMv) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.cellDeltaCritical,
        message:
            'Se detecta una diferencia elevada entre celdas. Contacte con soporte técnico si persiste.',
        finding: DiagnosticFinding(
          title: 'Diferencia elevada entre celdas',
          description:
              'La diferencia máxima entre celdas es de ${cellDeltaMv.round()} mV.',
          severity: AlarmSeverity.critical,
          recommendedAction:
              'Realice una carga completa. Si la diferencia persiste, contacte con soporte técnico INNPO.',
        ),
      );
    }

    if (cellDeltaMv >= profile.cellDeltaWarningThresholdMv) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.cellDeltaWarning,
        message:
            'Se detecta una diferencia relevante entre celdas. Revise la batería tras una carga completa.',
        finding: DiagnosticFinding(
          title: 'Diferencia relevante entre celdas',
          description:
              'La diferencia máxima entre celdas es de ${cellDeltaMv.round()} mV.',
          severity: AlarmSeverity.warning,
          recommendedAction:
              'Realice una carga completa y revise si el balanceo reduce la diferencia.',
        ),
      );
    }

    if (cellDeltaMv >= profile.cellDeltaOkThresholdMv) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.cellDeltaLightWarning,
        message:
            'Se detecta una ligera diferencia entre celdas. Realice una carga completa para facilitar el balanceo.',
        finding: DiagnosticFinding(
          title: 'Ligera diferencia entre celdas',
          description:
              'La diferencia máxima entre celdas es de ${cellDeltaMv.round()} mV.',
          severity: AlarmSeverity.warning,
          recommendedAction:
              'Realice una carga completa para facilitar el balanceo de celdas.',
        ),
      );
    }

    if (battery.socPercent < 10) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.lowSoc,
        message:
            'Nivel de carga muy bajo. Recargue la batería lo antes posible.',
        finding: DiagnosticFinding(
          title: 'SOC muy bajo',
          description:
              'La batería tiene un ${battery.socPercent.toStringAsFixed(0)}% de carga.',
          severity: AlarmSeverity.warning,
          recommendedAction:
              'Recargue la batería lo antes posible con un cargador compatible.',
        ),
      );
    }

    if (battery.cycleCount > profile.expectedCycleLife) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.highCycleCount,
        message:
            'La batería acumula un número elevado de ciclos. Revise su estado de salud.',
        finding: DiagnosticFinding(
          title: 'Ciclos elevados',
          description:
              'La batería acumula ${battery.cycleCount} ciclos. Vida esperada del perfil: ${profile.expectedCycleLife}.',
          severity: AlarmSeverity.warning,
          recommendedAction:
              'Revise el SOH, capacidad real y comportamiento bajo carga en la próxima revisión.',
        ),
      );
    }

    if (battery.activeAlarms.isEmpty) {
      return _DiagnosticRuleResult(
        rule: _DiagnosticRule.ok,
        message:
            'La batería funciona correctamente. No se detectan alarmas activas.',
        finding: const DiagnosticFinding(
          title: 'Estado correcto',
          description:
              'No hay alarmas activas y las celdas se encuentran dentro del umbral normal del perfil.',
          severity: AlarmSeverity.info,
          recommendedAction:
              'Continuar uso normal y revisar periódicamente el estado de la batería.',
        ),
      );
    }

    final highestAlarm = [...battery.activeAlarms]
      ..sort((a, b) => _severityRank(b.severity).compareTo(_severityRank(a.severity)));
    final alarm = highestAlarm.first;
    return _DiagnosticRuleResult(
      rule: _DiagnosticRule.genericAlarm,
      message: alarm.userFriendlyDescription,
      finding: DiagnosticFinding(
        title: alarm.title,
        description: alarm.userFriendlyDescription,
        severity: alarm.severity,
        recommendedAction: alarm.recommendedAction,
      ),
    );
  }

  bool _isLowTemperatureChargeBlocked(
    BatteryData battery,
    BatteryProfile profile,
  ) {
    final hasLowTemperatureAlarm = battery.activeAlarms.any(
      (alarm) =>
          alarm.category == AlarmCategory.temperature &&
          alarm.title.toLowerCase().contains('baja'),
    );
    return battery.temperatureMin <= profile.minChargeTemperature &&
        (!battery.chargeMosfetEnabled ||
            battery.operationStatus == BatteryOperationStatus.protection ||
            hasLowTemperatureAlarm);
  }

  bool _hasHighTemperature(BatteryData battery, BatteryProfile profile) {
    final maxTemperature = battery.current > 0
        ? profile.maxChargeTemperature
        : profile.maxDischargeTemperature;
    return battery.temperatureMax >= maxTemperature ||
        battery.activeAlarms.any(
          (alarm) =>
              alarm.category == AlarmCategory.temperature &&
              alarm.severity == AlarmSeverity.critical &&
              alarm.title.toLowerCase().contains('alta'),
        );
  }

  bool _hasOverCurrent(BatteryData battery, BatteryProfile profile) {
    final threshold = battery.current > 0
        ? profile.maxChargeCurrent
        : profile.maxDischargeCurrent;
    return battery.current.abs() > threshold ||
        battery.activeAlarms.any(
          (alarm) =>
              alarm.category == AlarmCategory.current ||
              alarm.code.toLowerCase().contains('current') ||
              alarm.title.toLowerCase().contains('corriente'),
        );
  }

  List<DiagnosticFinding> _alarmFindings(
    BatteryData battery, {
    required _DiagnosticRule skipCoveredBy,
  }) {
    if (skipCoveredBy == _DiagnosticRule.genericAlarm) {
      return const [];
    }
    return [
      for (final alarm in battery.activeAlarms)
        if (!_isCoveredAlarm(alarm, skipCoveredBy))
          DiagnosticFinding(
            title: alarm.title,
            description: alarm.userFriendlyDescription,
            severity: alarm.severity,
            recommendedAction: alarm.recommendedAction,
          ),
    ];
  }

  bool _isCoveredAlarm(AlarmData alarm, _DiagnosticRule rule) {
    return switch (rule) {
      _DiagnosticRule.lowTemperatureCharge =>
        alarm.category == AlarmCategory.temperature ||
            alarm.category == AlarmCategory.mosfet,
      _DiagnosticRule.highTemperature => alarm.category == AlarmCategory.temperature,
      _DiagnosticRule.overCurrent => alarm.category == AlarmCategory.current,
      _ => false,
    };
  }

  DiagnosticStatus _statusFor(List<DiagnosticFinding> findings) {
    if (findings.any((finding) => finding.severity == AlarmSeverity.critical)) {
      return DiagnosticStatus.critical;
    }
    if (findings.any((finding) => finding.severity == AlarmSeverity.warning)) {
      return DiagnosticStatus.warning;
    }
    return DiagnosticStatus.ok;
  }

  DiagnosticReport _unknownReport() {
    final battery = _emptyBatteryData();
    return DiagnosticReport(
      reportId: 'diag-${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
      batteryData: battery,
      status: DiagnosticStatus.unknown,
      findings: const [
        DiagnosticFinding(
          title: 'Sin datos suficientes',
          description: 'No hay datos suficientes para realizar el diagnóstico.',
          severity: AlarmSeverity.info,
          recommendedAction: 'Conecte una batería y espere a recibir una lectura válida del BMS.',
        ),
      ],
      recommendations: const [
        'Conecte una batería y espere a recibir una lectura válida del BMS.',
      ],
      summaryText: 'No hay datos suficientes para realizar el diagnóstico.',
    );
  }

  BatteryData _emptyBatteryData() {
    return BatteryData(
      deviceId: 'unknown',
      deviceName: 'Sin datos',
      serialNumber: null,
      modelName: null,
      firmwareVersion: null,
      timestamp: DateTime.now(),
      totalVoltage: 0,
      current: 0,
      power: 0,
      socPercent: 0,
      remainingCapacityAh: 0,
      nominalCapacityAh: 0,
      cycleCount: 0,
      operationStatus: BatteryOperationStatus.unknown,
      temperatures: const [],
      cells: const [],
      minCellVoltage: 0,
      maxCellVoltage: 0,
      cellVoltageDelta: 0,
      minCellIndex: null,
      maxCellIndex: null,
      isBalancing: false,
      balancingCellIndexes: const [],
      chargeMosfetEnabled: false,
      dischargeMosfetEnabled: false,
      activeAlarms: const [],
      rssi: null,
      isConnected: false,
    );
  }

  static int _severityRank(AlarmSeverity severity) {
    return switch (severity) {
      AlarmSeverity.info => 0,
      AlarmSeverity.warning => 1,
      AlarmSeverity.critical => 2,
    };
  }
}

class _DiagnosticRuleResult {
  const _DiagnosticRuleResult({
    required this.rule,
    required this.message,
    required this.finding,
  });

  final _DiagnosticRule rule;
  final String message;
  final DiagnosticFinding finding;
}

enum _DiagnosticRule {
  unknown,
  ok,
  cellDeltaLightWarning,
  cellDeltaWarning,
  cellDeltaCritical,
  lowTemperatureCharge,
  highTemperature,
  overCurrent,
  mosfetBlocked,
  lowSoc,
  highCycleCount,
  genericAlarm,
}

typedef DiagnosticEngine = BatteryDiagnosticService;
