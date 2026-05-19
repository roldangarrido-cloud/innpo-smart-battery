import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/features/battery/domain/models/battery_data.dart';
import 'package:innpo_smart_battery/features/battery/domain/models/diagnostic_report.dart';
import 'package:innpo_smart_battery/features/battery/domain/services/battery_diagnostic_service.dart';

void main() {
  group('BatteryDiagnosticService', () {
    const service = BatteryDiagnosticService();

    test('returns ok for a healthy battery', () {
      final report = service.evaluate(_battery());

      expect(report.status, DiagnosticStatus.ok);
      expect(
        report.summaryText,
        'La batería funciona correctamente. No se detectan alarmas activas.',
      );
    });

    test('returns warning for light cell delta', () {
      final report = service.evaluate(_battery(cellVoltages: [3.330, 3.355, 3.340, 3.338]));

      expect(report.status, DiagnosticStatus.warning);
      expect(report.summaryText, contains('ligera diferencia'));
    });

    test('returns critical for critical cell delta', () {
      final report = service.evaluate(_battery(cellVoltages: [3.180, 3.340, 3.338, 3.336]));

      expect(report.status, DiagnosticStatus.critical);
      expect(report.findings.first.title, 'Diferencia elevada entre celdas');
    });

    test('returns critical for low temperature charge block', () {
      final report = service.evaluate(_battery(
        temperatures: [-4, -2],
        chargeMosfetEnabled: false,
        operationStatus: BatteryOperationStatus.protection,
      ));

      expect(report.status, DiagnosticStatus.critical);
      expect(report.summaryText, contains('baja temperatura'));
    });

    test('returns critical for overcurrent', () {
      final report = service.evaluate(_battery(current: -145));

      expect(report.status, DiagnosticStatus.critical);
      expect(report.summaryText, contains('corriente superior'));
    });

    test('returns warning for low SOC', () {
      final report = service.evaluate(_battery(socPercent: 8));

      expect(report.status, DiagnosticStatus.warning);
      expect(report.summaryText, contains('Nivel de carga muy bajo'));
    });

    test('returns critical for blocked MOSFET', () {
      final report = service.evaluate(_battery(dischargeMosfetEnabled: false));

      expect(report.status, DiagnosticStatus.critical);
      expect(report.summaryText, 'Descarga bloqueada.');
    });
  });
}

BatteryData _battery({
  List<double> cellVoltages = const [3.330, 3.336, 3.334, 3.332],
  List<double> temperatures = const [24, 28],
  double current = 0,
  double socPercent = 80,
  bool chargeMosfetEnabled = true,
  bool dischargeMosfetEnabled = true,
  BatteryOperationStatus operationStatus = BatteryOperationStatus.idle,
}) {
  final cells = [
    for (var i = 0; i < cellVoltages.length; i++)
      CellData(
        index: i + 1,
        voltage: cellVoltages[i],
        isBalancing: false,
        status: CellStatus.normal,
      ),
  ];
  final minCell = cells.reduce((a, b) => a.voltage < b.voltage ? a : b);
  final maxCell = cells.reduce((a, b) => a.voltage > b.voltage ? a : b);
  final totalVoltage = cellVoltages.reduce((a, b) => a + b);

  return BatteryData(
    deviceId: 'test-battery',
    deviceName: 'INNPO Test',
    serialNumber: 'TEST-001',
    modelName: 'INNPO-LFP-12.8V-100Ah',
    firmwareVersion: 'test-1.0.0',
    timestamp: DateTime(2026, 5, 19),
    totalVoltage: totalVoltage,
    current: current,
    power: totalVoltage * current,
    socPercent: socPercent,
    sohPercent: 96,
    remainingCapacityAh: socPercent,
    nominalCapacityAh: 100,
    cycleCount: 20,
    operationStatus: operationStatus,
    temperatures: [
      for (var i = 0; i < temperatures.length; i++)
        TemperatureSensorData(
          id: 't$i',
          label: 'Sensor $i',
          celsius: temperatures[i],
        ),
    ],
    cells: cells,
    minCellVoltage: minCell.voltage,
    maxCellVoltage: maxCell.voltage,
    cellVoltageDelta: maxCell.voltage - minCell.voltage,
    minCellIndex: minCell.index,
    maxCellIndex: maxCell.index,
    isBalancing: false,
    balancingCellIndexes: const [],
    chargeMosfetEnabled: chargeMosfetEnabled,
    dischargeMosfetEnabled: dischargeMosfetEnabled,
    activeAlarms: const [],
    rssi: -52,
    isConnected: true,
  );
}

