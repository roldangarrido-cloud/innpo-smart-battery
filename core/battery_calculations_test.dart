import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/core/utils/battery_calculations.dart';
import 'package:innpo_smart_battery/features/battery/domain/models/battery_data.dart';

void main() {
  group('BatteryCalculations', () {
    test('calculates power as voltage times current', () {
      expect(BatteryCalculations.power(voltage: 13.2, current: -10), -132);
    });

    test('calculates min and max cell voltage', () {
      final cells = _cells([3.330, 3.345, 3.320, 3.338]);

      expect(BatteryCalculations.minCellVoltage(cells), 3.320);
      expect(BatteryCalculations.maxCellVoltage(cells), 3.345);
    });

    test('calculates cell delta', () {
      final cells = _cells([3.330, 3.345, 3.320, 3.338]);

      expect(BatteryCalculations.cellDelta(cells), closeTo(0.025, 0.0001));
    });

    test('estimates remaining time', () {
      final remaining = BatteryCalculations.estimatedRemainingTime(
        remainingCapacityAh: 50,
        currentA: -10,
      );

      expect(remaining, const Duration(hours: 5));
    });
  });
}

List<CellData> _cells(List<double> voltages) {
  return [
    for (var i = 0; i < voltages.length; i++)
      CellData(
        index: i + 1,
        voltage: voltages[i],
        isBalancing: false,
        status: CellStatus.normal,
      ),
  ];
}

