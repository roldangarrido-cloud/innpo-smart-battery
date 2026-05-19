import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/app/theme/app_theme.dart';
import 'package:innpo_smart_battery/features/battery/application/battery_providers.dart';
import 'package:innpo_smart_battery/features/battery/domain/models/battery_data.dart';
import 'package:innpo_smart_battery/features/battery/domain/models/diagnostic_report.dart';
import 'package:innpo_smart_battery/features/battery/presentation/screens/battery_dashboard_screen.dart';
import 'package:innpo_smart_battery/features/battery/presentation/widgets/alarm_card.dart';
import 'package:innpo_smart_battery/features/battery/presentation/widgets/demo_mode_badge.dart';

void main() {
  testWidgets('dashboard renders battery data', (tester) async {
    final battery = _battery(deviceId: 'ui-battery');
    final report = _report(battery);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          batteryStatusProvider('ui-battery').overrideWith(
            (ref) => Stream.value(battery),
          ),
          diagnosticSummaryProvider('ui-battery').overrideWith(
            (ref) => AsyncValue.data(report),
          ),
        ],
        child: MaterialApp(
          theme: InnpoTheme.light(),
          home: const BatteryDashboardScreen(batteryId: 'ui-battery'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('INNPO Test'), findsWidgets);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('Voltaje total'), findsOneWidget);
  });

  testWidgets('critical alarm appears', (tester) async {
    final alarm = AlarmData(
      code: 'CRIT',
      title: 'Alarma crítica',
      technicalDescription: 'Mock critical alarm',
      userFriendlyDescription: 'Protección activa del BMS.',
      severity: AlarmSeverity.critical,
      recommendedAction: 'Detener uso y revisar.',
      timestamp: DateTime(2026, 5, 19),
      isActive: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: InnpoTheme.light(),
        home: Scaffold(body: AlarmCard(alarm: alarm)),
      ),
    );

    expect(find.text('Alarma crítica'), findsOneWidget);
    expect(find.text('Protección activa del BMS.'), findsOneWidget);
  });

  testWidgets('demo mode badge is visible for mock battery', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: InnpoTheme.light(),
        home: const Scaffold(
          body: DemoModeBadge(batteryId: 'mock-12v-100ah'),
        ),
      ),
    );

    expect(find.text('MODO DEMO'), findsOneWidget);
  });
}

BatteryData _battery({required String deviceId}) {
  const cells = [
    CellData(index: 1, voltage: 3.330, isBalancing: false, status: CellStatus.normal),
    CellData(index: 2, voltage: 3.334, isBalancing: false, status: CellStatus.normal),
    CellData(index: 3, voltage: 3.332, isBalancing: false, status: CellStatus.normal),
    CellData(index: 4, voltage: 3.336, isBalancing: false, status: CellStatus.normal),
  ];
  return BatteryData(
    deviceId: deviceId,
    deviceName: 'INNPO Test',
    serialNumber: 'TEST-UI',
    modelName: 'INNPO-LFP-12.8V-100Ah',
    firmwareVersion: 'ui-1.0.0',
    timestamp: DateTime(2026, 5, 19),
    totalVoltage: 13.2,
    current: 0,
    power: 0,
    socPercent: 80,
    sohPercent: 96,
    remainingCapacityAh: 80,
    nominalCapacityAh: 100,
    cycleCount: 12,
    operationStatus: BatteryOperationStatus.idle,
    temperatures: const [
      TemperatureSensorData(id: 't1', label: 'BMS', celsius: 24),
      TemperatureSensorData(id: 't2', label: 'Pack', celsius: 28),
    ],
    cells: cells,
    minCellVoltage: 3.330,
    maxCellVoltage: 3.336,
    cellVoltageDelta: 0.006,
    minCellIndex: 1,
    maxCellIndex: 4,
    isBalancing: false,
    balancingCellIndexes: const [],
    chargeMosfetEnabled: true,
    dischargeMosfetEnabled: true,
    activeAlarms: const [],
    rssi: -50,
    isConnected: true,
  );
}

DiagnosticReport _report(BatteryData battery) {
  return DiagnosticReport(
    reportId: 'ui-report',
    createdAt: DateTime(2026, 5, 19),
    batteryData: battery,
    status: DiagnosticStatus.ok,
    findings: const [],
    recommendations: const [],
    summaryText: 'La batería funciona correctamente. No se detectan alarmas activas.',
  );
}

