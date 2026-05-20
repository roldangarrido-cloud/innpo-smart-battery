import '../models/battery_data.dart';
import '../models/battery_profile.dart';

class BatteryCompatibilityResult {
  const BatteryCompatibilityResult({
    required this.compatible,
    required this.reason,
    this.issues = const [],
  });

  final bool compatible;
  final String reason;
  final List<String> issues;
}

class BatteryCompatibilityService {
  const BatteryCompatibilityService();

  BatteryCompatibilityResult canApplyConfiguration(
    BatteryData battery,
    BatteryProfile profile,
  ) {
    final issues = <String>[];
    final currentProfile = BatteryProfile.fromBatteryData(battery);

    if (profile.chemistry != BatteryChemistry.unknown &&
        currentProfile.chemistry != BatteryChemistry.unknown &&
        profile.chemistry != currentProfile.chemistry) {
      issues.add('La química no coincide con la batería conectada.');
    }

    if (battery.cells.isNotEmpty && battery.cells.length != profile.seriesCellCount) {
      issues.add(
        'La batería tiene ${battery.cells.length} celdas y el perfil requiere ${profile.seriesCellCount}.',
      );
    }

    final voltageDelta = (battery.totalVoltage - profile.nominalVoltage).abs();
    if (voltageDelta > profile.nominalVoltage * 0.08) {
      issues.add('El voltaje nominal no coincide con el perfil seleccionado.');
    }

    final capacityDelta =
        (battery.nominalCapacityAh - profile.nominalCapacityAh).abs();
    if (capacityDelta > profile.nominalCapacityAh * 0.25) {
      issues.add('La capacidad nominal no coincide con el perfil seleccionado.');
    }

    final modelName = battery.modelName?.toLowerCase();
    if (modelName != null &&
        modelName.isNotEmpty &&
        profile.name.toLowerCase().contains('golf') != modelName.contains('golf') &&
        !profile.name.toLowerCase().contains('generic')) {
      issues.add('El modelo BMS no coincide claramente con el perfil.');
    }

    final firmware = battery.firmwareVersion;
    if (firmware == null || firmware.isEmpty) {
      issues.add('No se ha podido verificar firmware del BMS.');
    }

    if (issues.isNotEmpty) {
      return BatteryCompatibilityResult(
        compatible: false,
        reason: issues.first,
        issues: issues,
      );
    }

    return const BatteryCompatibilityResult(
      compatible: true,
      reason: 'Perfil compatible con la batería conectada.',
    );
  }
}
