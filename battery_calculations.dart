import '../../features/battery/domain/models/battery_data.dart';

class BatteryCalculations {
  const BatteryCalculations._();

  static double cellDelta(List<CellData> cells) {
    if (cells.isEmpty) {
      return 0;
    }
    final values = cells.map((cell) => cell.voltage);
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return max - min;
  }

  static double minCellVoltage(List<CellData> cells) {
    if (cells.isEmpty) {
      return 0;
    }
    return cells.map((cell) => cell.voltage).reduce((a, b) => a < b ? a : b);
  }

  static double maxCellVoltage(List<CellData> cells) {
    if (cells.isEmpty) {
      return 0;
    }
    return cells.map((cell) => cell.voltage).reduce((a, b) => a > b ? a : b);
  }

  static double power({required double voltage, required double current}) {
    return voltage * current;
  }

  static Duration? estimatedRemainingTime({
    required double remainingCapacityAh,
    required double currentA,
  }) {
    final load = currentA.abs();
    if (load <= 0) {
      return null;
    }
    final hours = remainingCapacityAh / load;
    return Duration(minutes: (hours * 60).round());
  }
}
