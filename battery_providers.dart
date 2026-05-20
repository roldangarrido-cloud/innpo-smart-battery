import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/permissions/permissions_service.dart';
import '../../../core/logging/local_event_log.dart';
import '../../bluetooth/data/ble_connection_service.dart';
import '../../bluetooth/data/ble_repository_impl.dart';
import '../../bluetooth/data/ble_scanner_service.dart';
import '../../bluetooth/domain/ble_repository.dart';
import '../data/battery_history_repository.dart';
import '../data/bms_ble_data_source.dart';
import '../data/bms_parser.dart';
import '../data/known_battery_repository.dart';
import '../domain/bms_repository.dart';
import '../domain/models/battery_data.dart';
import '../domain/models/diagnostic_report.dart';
import '../domain/models/history_sample.dart';
import '../domain/services/battery_diagnostic_service.dart';

final bleGatewayProvider = Provider<BleRepository>((ref) => BleRepositoryImpl());

final permissionsServiceProvider = Provider<PermissionsService>(
  (ref) => PermissionsService(),
);

final bleScannerServiceProvider = Provider<BleScannerService>((ref) {
  return BleScannerService(
    repository: ref.watch(bleGatewayProvider),
    permissionsService: ref.watch(permissionsServiceProvider),
  );
});

final bleConnectionServiceProvider = Provider<BleConnectionService>((ref) {
  return BleConnectionService(repository: ref.watch(bleGatewayProvider));
});

final mockBatteryProfileProvider = StateProvider<MockBatteryProfile>(
  (ref) => MockBatteryProfile.innpo12v100ah,
);

final mockBmsDemoStateProvider = StateProvider<MockBmsDemoState>(
  (ref) => MockBmsDemoState.normal,
);

final mockBmsDemoCaseProvider = StateProvider<MockBmsDemoCase>(
  (ref) => MockBmsDemoCase.healthy12v,
);

final bmsParserProvider = Provider<BmsParser>(
  (ref) => MockBmsParser(
    profile: ref.watch(mockBatteryProfileProvider),
    demoState: ref.watch(mockBmsDemoStateProvider),
  ),
);

final bmsBleDataSourceProvider = Provider<BmsBleDataSource>((ref) {
  return BmsBleDataSource(
    connectionService: ref.watch(bleConnectionServiceProvider),
    parser: ref.watch(bmsParserProvider),
  );
});

final batteryRepositoryProvider = Provider<BatteryRepository>((ref) {
  return BleBatteryRepository(
    scannerService: ref.watch(bleScannerServiceProvider),
    connectionService: ref.watch(bleConnectionServiceProvider),
    dataSource: ref.watch(bmsBleDataSourceProvider),
  );
});

final knownBatteryRepositoryProvider = Provider<KnownBatteryRepository>(
  (ref) => KnownBatteryRepository(),
);

final bmsRepositoryProvider = Provider<BmsRepository>((ref) {
  return ref.watch(batteryRepositoryProvider) as BmsRepository;
});

final batteryScanProvider = StreamProvider<List<BleBatteryDevice>>((ref) {
  return ref.watch(batteryRepositoryProvider).scan();
});

final historySampleIntervalProvider = StateProvider<Duration>(
  (ref) => const Duration(seconds: 30),
);

final batteryHistoryRepositoryProvider = Provider<BatteryHistoryRepository>(
  (ref) => BatteryHistoryRepository(
    sampleInterval: ref.watch(historySampleIntervalProvider),
  ),
);

final batteryStatusProvider =
    StreamProvider.family<BatteryData, String>((ref, deviceId) async* {
  final repository = ref.watch(batteryRepositoryProvider);
  final historyRepository = ref.watch(batteryHistoryRepositoryProvider);
  await repository.connect(deviceId);
  await for (final data in repository.watchStatus(deviceId)) {
    await historyRepository.recordIfDue(data);
    for (final alarm in data.activeAlarms) {
      await LocalEventLogRepository().record(
        type: AppLogEventType.alarmDetected,
        message: alarm.title,
        deviceId: data.deviceId,
        details: {
          'code': alarm.code,
          'severity': alarm.severity.name,
        },
      );
    }
    yield data;
  }
});

final historyRangeProvider = StateProvider<HistoryRange>(
  (ref) => HistoryRange.lastHour,
);

final batteryHistoryProvider =
    Provider.family<List<BatteryHistorySample>, String>((ref, deviceId) {
  final range = ref.watch(historyRangeProvider);
  final samples = ref.watch(batteryHistoryRepositoryProvider).getSamples(
        deviceId: deviceId,
        range: range,
      );
  if (samples.isNotEmpty || !MockBmsParser.isMockDeviceId(deviceId)) {
    return samples;
  }
  return _buildDemoHistorySamples(
    deviceId: deviceId,
    range: range,
    state: ref.watch(mockBmsDemoStateProvider),
  );
});

final diagnosticEngineProvider = Provider<DiagnosticEngine>(
  (ref) => DiagnosticEngine(),
);

final diagnosticSummaryProvider =
    Provider.family<AsyncValue<DiagnosticReport>, String>((ref, deviceId) {
  final status = ref.watch(batteryStatusProvider(deviceId));
  return status.whenData(ref.watch(diagnosticEngineProvider).evaluate);
});

List<BatteryHistorySample> _buildDemoHistorySamples({
  required String deviceId,
  required HistoryRange range,
  required MockBmsDemoState state,
}) {
  final now = DateTime.now();
  final start = range.start(now) ?? now.subtract(const Duration(days: 30));
  final totalMinutes =
      now.difference(start).inMinutes.clamp(60, 60 * 24 * 30).toInt();
  final stepMinutes = totalMinutes > 60 * 24 * 7 ? 240 : totalMinutes > 360 ? 60 : 5;
  final alarmCount = switch (state) {
    MockBmsDemoState.normal ||
    MockBmsDemoState.charging ||
    MockBmsDemoState.discharging => 0,
    _ => 1,
  };
  final currentBase = switch (state) {
    MockBmsDemoState.charging => 24.0,
    MockBmsDemoState.discharging => -18.0,
    MockBmsDemoState.overCurrent => -145.0,
    _ => 0.0,
  };
  final deltaBase = state == MockBmsDemoState.cellImbalance ? 0.145 : 0.008;
  final samples = <BatteryHistorySample>[];
  for (var minute = 0; minute <= totalMinutes; minute += stepMinutes) {
    final timestamp = start.add(Duration(minutes: minute));
    final progress = minute / totalMinutes;
    final soc = switch (state) {
      MockBmsDemoState.charging => 52 + (progress * 28),
      MockBmsDemoState.discharging => 82 - (progress * 24),
      MockBmsDemoState.underVoltage => 10 - (progress * 2),
      _ => 76 + ((minute ~/ stepMinutes) % 4),
    };
    final voltage = switch (deviceId) {
      'mock-24v-100ah' => 26.1 + (progress * 0.4),
      'mock-golf-51v-100ah' => 52.2 + (progress * 0.8),
      _ => 13.0 + (progress * 0.25),
    };
    final current = currentBase == 0 ? ((minute ~/ stepMinutes) % 3) * 0.2 : currentBase;
    samples.add(
      BatteryHistorySample(
        deviceId: deviceId,
        timestamp: timestamp,
        socPercent: soc.clamp(0, 100).toDouble(),
        totalVoltage: voltage,
        current: current,
        power: voltage * current,
        temperatureMax: state == MockBmsDemoState.lowTemperature
            ? -2
            : state == MockBmsDemoState.highTemperature
                ? 58
                : 28 + ((minute ~/ stepMinutes) % 5),
        cycleCount: 128,
        activeAlarmCount: alarmCount,
        cellVoltageDelta: deltaBase,
      ),
    );
  }
  return samples;
}
