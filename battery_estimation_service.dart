class BatteryEstimationService {
  const BatteryEstimationService();

  Duration estimateRuntime({
    required double capacityAh,
    required int soc,
    required double currentA,
  }) {
    if (currentA.abs() < 0.1) {
      return Duration.zero;
    }
    final remainingAh = capacityAh * (soc / 100);
    return Duration(minutes: ((remainingAh / currentA.abs()) * 60).round());
  }
}

