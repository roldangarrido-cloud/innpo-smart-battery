import '../domain/models/battery_data.dart';

/// Contract between raw BMS frames and app domain models.
///
/// The manufacturer-specific implementation should replace only this parser
/// when real UUIDs, commands, frame layout and checksum rules are available.
abstract interface class BmsParser {
  BatteryData parseBatteryStatus(List<int> frame);
  List<CellData> parseCellVoltages(List<int> frame);
  List<AlarmData> parseAlarms(List<int> frame);
  List<int> buildReadStatusCommand();
  List<int> buildReadCellsCommand();
  List<int> buildReadAlarmsCommand();
}

enum MockBatteryProfile {
  innpo12v100ah,
  innpo24v100ah,
  innpoGolf51v100ah,
}

enum MockBmsDemoState {
  normal,
  charging,
  discharging,
  warning,
  critical,
  cellImbalance,
  lowTemperature,
  highTemperature,
  overVoltage,
  underVoltage,
  overCurrent,
  chargeBlocked,
  dischargeBlocked,
}

enum MockBmsDemoCase {
  healthy12v,
  healthy24v,
  golf51v,
  charging,
  discharging,
  lowTemperature,
  overCurrent,
  cellImbalance,
  chargeMosfetBlocked,
  critical,
}

extension MockBmsDemoCaseSpec on MockBmsDemoCase {
  String get title {
    return switch (this) {
      MockBmsDemoCase.healthy12v => 'Bateria correcta 12.8V 100Ah',
      MockBmsDemoCase.healthy24v => 'Bateria correcta 25.6V 100Ah',
      MockBmsDemoCase.golf51v => 'Bateria golf 51.2V 100Ah',
      MockBmsDemoCase.charging => 'Bateria cargando',
      MockBmsDemoCase.discharging => 'Bateria descargando',
      MockBmsDemoCase.lowTemperature => 'Alarma baja temperatura',
      MockBmsDemoCase.overCurrent => 'Alarma sobrecorriente',
      MockBmsDemoCase.cellImbalance => 'Celdas desequilibradas',
      MockBmsDemoCase.chargeMosfetBlocked => 'MOSFET carga bloqueado',
      MockBmsDemoCase.critical => 'Estado critico',
    };
  }

  String get description {
    return switch (this) {
      MockBmsDemoCase.healthy12v => 'Pack LiFePO4 4S al 80%, sin alarmas.',
      MockBmsDemoCase.healthy24v => 'Pack LiFePO4 8S al 76%, sin alarmas.',
      MockBmsDemoCase.golf51v => 'Pack golf 16S al 68%, preparado para flotas.',
      MockBmsDemoCase.charging => 'Corriente positiva y estado operativo cargando.',
      MockBmsDemoCase.discharging => 'Corriente negativa y autonomia estimada visible.',
      MockBmsDemoCase.lowTemperature => 'Proteccion por temperatura baja de carga.',
      MockBmsDemoCase.overCurrent => 'Proteccion por corriente excesiva.',
      MockBmsDemoCase.cellImbalance => 'Delta elevado entre celdas y balanceo activo.',
      MockBmsDemoCase.chargeMosfetBlocked => 'Carga deshabilitada por el BMS.',
      MockBmsDemoCase.critical => 'Alarma critica general y proteccion activa.',
    };
  }

  MockBatteryProfile get profile {
    return switch (this) {
      MockBmsDemoCase.healthy24v => MockBatteryProfile.innpo24v100ah,
      MockBmsDemoCase.golf51v => MockBatteryProfile.innpoGolf51v100ah,
      _ => MockBatteryProfile.innpo12v100ah,
    };
  }

  MockBmsDemoState get state {
    return switch (this) {
      MockBmsDemoCase.charging => MockBmsDemoState.charging,
      MockBmsDemoCase.discharging => MockBmsDemoState.discharging,
      MockBmsDemoCase.lowTemperature => MockBmsDemoState.lowTemperature,
      MockBmsDemoCase.overCurrent => MockBmsDemoState.overCurrent,
      MockBmsDemoCase.cellImbalance => MockBmsDemoState.cellImbalance,
      MockBmsDemoCase.chargeMosfetBlocked => MockBmsDemoState.chargeBlocked,
      MockBmsDemoCase.critical => MockBmsDemoState.critical,
      _ => MockBmsDemoState.normal,
    };
  }
}

class MockBmsProfileSpec {
  const MockBmsProfileSpec({
    required this.deviceId,
    required this.deviceName,
    required this.modelName,
    required this.serialNumber,
    required this.cellCount,
    required this.nominalVoltage,
    required this.nominalCapacityAh,
    required this.baseSocPercent,
    required this.baseTotalVoltage,
  });

  final String deviceId;
  final String deviceName;
  final String modelName;
  final String serialNumber;
  final int cellCount;
  final double nominalVoltage;
  final double nominalCapacityAh;
  final double baseSocPercent;
  final double baseTotalVoltage;
}

/// Deterministic BMS simulator used by demo mode and tests while hardware
/// protocol details are pending.
class MockBmsParser implements BmsParser {
  MockBmsParser({
    this.profile = MockBatteryProfile.innpo12v100ah,
    this.demoState = MockBmsDemoState.normal,
  });

  final MockBatteryProfile profile;
  final MockBmsDemoState demoState;
  int _tick = 0;

  static const profileSpecs = {
    MockBatteryProfile.innpo12v100ah: MockBmsProfileSpec(
      deviceId: 'mock-12v-100ah',
      deviceName: 'INNPO LiFePO4 12.8V 100Ah',
      modelName: 'INNPO-LFP-12.8V-100Ah',
      serialNumber: 'INNPO-12V-MOCK-001',
      cellCount: 4,
      nominalVoltage: 12.8,
      nominalCapacityAh: 100,
      baseSocPercent: 80,
      baseTotalVoltage: 13.2,
    ),
    MockBatteryProfile.innpo24v100ah: MockBmsProfileSpec(
      deviceId: 'mock-24v-100ah',
      deviceName: 'INNPO LiFePO4 25.6V 100Ah',
      modelName: 'INNPO-LFP-25.6V-100Ah',
      serialNumber: 'INNPO-24V-MOCK-001',
      cellCount: 8,
      nominalVoltage: 25.6,
      nominalCapacityAh: 100,
      baseSocPercent: 76,
      baseTotalVoltage: 26.4,
    ),
    MockBatteryProfile.innpoGolf51v100ah: MockBmsProfileSpec(
      deviceId: 'mock-golf-51v-100ah',
      deviceName: 'INNPO Golf Battery 51.2V 100Ah',
      modelName: 'INNPO-GOLF-51.2V-100Ah',
      serialNumber: 'INNPO-GOLF-MOCK-001',
      cellCount: 16,
      nominalVoltage: 51.2,
      nominalCapacityAh: 100,
      baseSocPercent: 68,
      baseTotalVoltage: 52.8,
    ),
  };

  static bool isMockDeviceId(String deviceId) {
    return profileSpecs.values.any((spec) => spec.deviceId == deviceId);
  }

  static MockBatteryProfile? profileForDeviceId(String deviceId) {
    for (final entry in profileSpecs.entries) {
      if (entry.value.deviceId == deviceId) {
        return entry.key;
      }
    }
    return null;
  }

  static String deviceIdForProfile(MockBatteryProfile profile) {
    return profileSpecs[profile]!.deviceId;
  }

  @override
  BatteryData parseBatteryStatus(List<int> frame) {
    _tick++;
    final spec = profileSpecs[profile]!;
    final cells = parseCellVoltages(frame);
    final minCell = cells.reduce((a, b) => a.voltage < b.voltage ? a : b);
    final maxCell = cells.reduce((a, b) => a.voltage > b.voltage ? a : b);
    final balancingCellIndexes = [
      for (final cell in cells)
        if (cell.isBalancing) cell.index,
    ];
    final current = _currentForState();
    final totalVoltage = _totalVoltageForState(spec);
    final alarms = parseAlarms(frame);
    final chargeBlocked = demoState == MockBmsDemoState.chargeBlocked;
    final dischargeBlocked = demoState == MockBmsDemoState.dischargeBlocked;

    return BatteryData(
      deviceId: spec.deviceId,
      deviceName: spec.deviceName,
      modelName: spec.modelName,
      serialNumber: spec.serialNumber,
      firmwareVersion: 'mock-0.2.0',
      timestamp: DateTime.now(),
      totalVoltage: totalVoltage,
      current: current,
      power: totalVoltage * current,
      socPercent: _socForState(spec),
      sohPercent: 96,
      remainingCapacityAh: spec.nominalCapacityAh * (_socForState(spec) / 100),
      nominalCapacityAh: spec.nominalCapacityAh,
      cycleCount: 128,
      operationStatus: _operationStatusForState(alarms),
      temperatures: _temperaturesForState(),
      cells: cells,
      minCellVoltage: minCell.voltage,
      maxCellVoltage: maxCell.voltage,
      cellVoltageDelta: maxCell.voltage - minCell.voltage,
      minCellIndex: minCell.index,
      maxCellIndex: maxCell.index,
      isBalancing: balancingCellIndexes.isNotEmpty,
      balancingCellIndexes: balancingCellIndexes,
      chargeMosfetEnabled: !chargeBlocked,
      dischargeMosfetEnabled: !dischargeBlocked,
      activeAlarms: alarms,
      rssi: _rssiForProfile(),
      isConnected: true,
    );
  }

  @override
  List<CellData> parseCellVoltages(List<int> frame) {
    final spec = profileSpecs[profile]!;
    final averageVoltage = _totalVoltageForState(spec) / spec.cellCount;
    return List.generate(spec.cellCount, (index) {
      final isProblemCell =
          demoState == MockBmsDemoState.cellImbalance && index == 0;
      final voltage = isProblemCell
          ? averageVoltage - 0.18
          : averageVoltage + (((_tick + index) % 3) * 0.004);
      return CellData(
        index: index + 1,
        voltage: voltage,
        isBalancing: demoState == MockBmsDemoState.cellImbalance && index == 0,
        status: _cellStatusForVoltage(voltage, averageVoltage, isProblemCell),
      );
    });
  }

  @override
  List<AlarmData> parseAlarms(List<int> frame) {
    return switch (demoState) {
      MockBmsDemoState.warning => [
          _alarm(
            code: 'MOCK-WARN-001',
            title: 'Aviso general BMS',
            category: AlarmCategory.unknown,
            severity: AlarmSeverity.warning,
            userText: 'La bateria requiere supervision.',
            technicalText: 'Estado mock de aviso general.',
            action: 'Generar informe si el aviso persiste.',
          ),
        ],
      MockBmsDemoState.critical => [
          _alarm(
            code: 'MOCK-CRIT-001',
            title: 'Alarma critica BMS',
            category: AlarmCategory.hardware,
            severity: AlarmSeverity.critical,
            userText: 'La bateria requiere intervencion tecnica.',
            technicalText: 'Estado mock de alarma critica general.',
            action: 'Detener uso y contactar con soporte INNPO.',
          ),
        ],
      MockBmsDemoState.cellImbalance => [
          _alarm(
            code: 'MOCK-CELL-IMBALANCE',
            title: 'Celda desequilibrada',
            category: AlarmCategory.balancing,
            severity: AlarmSeverity.warning,
            userText: 'Una celda tiene voltaje diferente al resto.',
            technicalText: 'Delta de celdas elevado en escenario mock.',
            action: 'Realizar carga completa y revisar si persiste.',
          ),
        ],
      MockBmsDemoState.lowTemperature => [
          _alarm(
            code: 'MOCK-LOW-TEMP',
            title: 'Baja temperatura',
            category: AlarmCategory.temperature,
            severity: AlarmSeverity.warning,
            userText: 'La bateria esta demasiado fria para operar con normalidad.',
            technicalText: 'Sensor de temperatura por debajo de 0 C.',
            action: 'Esperar a que la bateria alcance temperatura segura.',
          ),
        ],
      MockBmsDemoState.highTemperature => [
          _alarm(
            code: 'MOCK-HIGH-TEMP',
            title: 'Alta temperatura',
            category: AlarmCategory.temperature,
            severity: AlarmSeverity.critical,
            userText: 'La bateria esta demasiado caliente.',
            technicalText: 'Sensor de temperatura por encima de 55 C.',
            action: 'Detener carga o descarga y mejorar ventilacion.',
          ),
        ],
      MockBmsDemoState.overVoltage => [
          _alarm(
            code: 'MOCK-OVERVOLT',
            title: 'Sobretension',
            category: AlarmCategory.voltage,
            severity: AlarmSeverity.critical,
            userText: 'El voltaje esta por encima del rango seguro.',
            technicalText: 'Pack voltage supera umbral mock de proteccion.',
            action: 'Detener carga y revisar cargador.',
          ),
        ],
      MockBmsDemoState.underVoltage => [
          _alarm(
            code: 'MOCK-UNDERVOLT',
            title: 'Bajo voltaje',
            category: AlarmCategory.voltage,
            severity: AlarmSeverity.critical,
            userText: 'La bateria esta descargada por debajo del rango seguro.',
            technicalText: 'Pack voltage bajo umbral mock de proteccion.',
            action: 'Detener descarga y cargar con cargador compatible.',
          ),
        ],
      MockBmsDemoState.overCurrent => [
          _alarm(
            code: 'MOCK-OVERCURRENT',
            title: 'Sobrecorriente',
            category: AlarmCategory.current,
            severity: AlarmSeverity.critical,
            userText: 'La demanda de corriente es demasiado alta.',
            technicalText: 'Corriente supera umbral mock de proteccion.',
            action: 'Reducir carga conectada y revisar instalacion.',
          ),
        ],
      MockBmsDemoState.chargeBlocked => [
          _alarm(
            code: 'MOCK-CHG-MOS-OFF',
            title: 'Carga bloqueada',
            category: AlarmCategory.mosfet,
            severity: AlarmSeverity.warning,
            userText: 'El BMS ha desactivado la carga.',
            technicalText: 'Charge MOSFET deshabilitado en escenario mock.',
            action: 'Revisar cargador, temperatura y alarmas activas.',
          ),
        ],
      MockBmsDemoState.dischargeBlocked => [
          _alarm(
            code: 'MOCK-DSG-MOS-OFF',
            title: 'Descarga bloqueada',
            category: AlarmCategory.mosfet,
            severity: AlarmSeverity.warning,
            userText: 'El BMS ha desactivado la descarga.',
            technicalText: 'Discharge MOSFET deshabilitado en escenario mock.',
            action: 'Reducir carga y revisar protecciones activas.',
          ),
        ],
      _ => const [],
    };
  }

  @override
  List<int> buildReadStatusCommand() => const [0x01, 0x03, 0x00];

  @override
  List<int> buildReadCellsCommand() => const [0x01, 0x04, 0x00];

  @override
  List<int> buildReadAlarmsCommand() => const [0x01, 0x05, 0x00];

  double _totalVoltageForState(MockBmsProfileSpec spec) {
    return switch (demoState) {
      MockBmsDemoState.overVoltage => spec.baseTotalVoltage * 1.08,
      MockBmsDemoState.underVoltage => spec.baseTotalVoltage * 0.82,
      _ => spec.baseTotalVoltage + ((_tick % 5) * 0.02),
    };
  }

  double _socForState(MockBmsProfileSpec spec) {
    return switch (demoState) {
      MockBmsDemoState.underVoltage => 8,
      MockBmsDemoState.overVoltage => 100,
      _ => spec.baseSocPercent,
    };
  }

  double _currentForState() {
    return switch (demoState) {
      MockBmsDemoState.charging => 24.0,
      MockBmsDemoState.discharging => -18.0,
      MockBmsDemoState.overCurrent => -145.0,
      MockBmsDemoState.chargeBlocked => 0,
      MockBmsDemoState.dischargeBlocked => 0,
      _ => 0,
    };
  }

  BatteryOperationStatus _operationStatusForState(List<AlarmData> alarms) {
    if (alarms.any((alarm) => alarm.severity == AlarmSeverity.critical)) {
      return BatteryOperationStatus.protection;
    }
    return switch (demoState) {
      MockBmsDemoState.charging => BatteryOperationStatus.charging,
      MockBmsDemoState.discharging => BatteryOperationStatus.discharging,
      MockBmsDemoState.overVoltage => BatteryOperationStatus.full,
      MockBmsDemoState.chargeBlocked => BatteryOperationStatus.protection,
      MockBmsDemoState.dischargeBlocked => BatteryOperationStatus.protection,
      _ => BatteryOperationStatus.idle,
    };
  }

  List<TemperatureSensorData> _temperaturesForState() {
    return switch (demoState) {
      MockBmsDemoState.lowTemperature => const [
          TemperatureSensorData(id: 't1', label: 'BMS', celsius: -4),
          TemperatureSensorData(id: 't2', label: 'Pack', celsius: -2),
        ],
      MockBmsDemoState.highTemperature => const [
          TemperatureSensorData(id: 't1', label: 'BMS', celsius: 58),
          TemperatureSensorData(id: 't2', label: 'Pack', celsius: 55),
        ],
      _ => [
          const TemperatureSensorData(id: 't1', label: 'BMS', celsius: 24.1),
          TemperatureSensorData(
            id: 't2',
            label: 'Pack',
            celsius: 31 + (_tick % 3),
          ),
        ],
    };
  }

  CellStatus _cellStatusForVoltage(
    double voltage,
    double averageVoltage,
    bool isProblemCell,
  ) {
    if (isProblemCell) {
      return CellStatus.warning;
    }
    if (voltage >= averageVoltage + 0.12) {
      return CellStatus.high;
    }
    if (voltage <= averageVoltage - 0.12) {
      return CellStatus.low;
    }
    return CellStatus.normal;
  }

  int _rssiForProfile() {
    return switch (profile) {
      MockBatteryProfile.innpo12v100ah => -48,
      MockBatteryProfile.innpo24v100ah => -56,
      MockBatteryProfile.innpoGolf51v100ah => -63,
    };
  }

  AlarmData _alarm({
    required String code,
    required String title,
    required AlarmCategory category,
    required AlarmSeverity severity,
    required String userText,
    required String technicalText,
    required String action,
  }) {
    return AlarmData(
      code: code,
      title: title,
      technicalDescription: technicalText,
      userFriendlyDescription: userText,
      severity: severity,
      recommendedAction: action,
      timestamp: DateTime.now(),
      isActive: true,
      category: category,
    );
  }
}
