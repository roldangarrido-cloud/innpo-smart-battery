import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/features/battery/data/bms_parser.dart';
import 'package:innpo_smart_battery/features/battery/domain/models/battery_data.dart';

void main() {
  group('MockBmsParser', () {
    test('generates valid BatteryData', () {
      final data = MockBmsParser().parseBatteryStatus(const []);

      expect(data.deviceId, 'mock-12v-100ah');
      expect(data.cells, hasLength(4));
      expect(data.isConnected, isTrue);
      expect(data.totalVoltage, greaterThan(0));
    });

    test('generates simulated alarms', () {
      final data = MockBmsParser(
        demoState: MockBmsDemoState.lowTemperature,
      ).parseBatteryStatus(const []);

      expect(data.activeAlarms, isNotEmpty);
      expect(data.activeAlarms.first.category, AlarmCategory.temperature);
    });

    test('generates different profiles', () {
      final profiles = {
        MockBatteryProfile.innpo12v100ah: 4,
        MockBatteryProfile.innpo24v100ah: 8,
        MockBatteryProfile.innpoGolf51v100ah: 16,
      };

      for (final entry in profiles.entries) {
        final data = MockBmsParser(profile: entry.key).parseBatteryStatus(const []);
        expect(data.cells, hasLength(entry.value));
      }
    });
  });
}

