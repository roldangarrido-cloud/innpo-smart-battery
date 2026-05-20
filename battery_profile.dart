import 'battery_data.dart';

enum BatteryChemistry {
  lifepo4,
  lithiumIon,
  leadAcid,
  unknown,
}

class BatteryProfile {
  const BatteryProfile({
    required this.id,
    required this.name,
    required this.chemistry,
    required this.seriesCellCount,
    required this.nominalVoltage,
    required this.nominalCapacityAh,
    required this.minCellVoltage,
    required this.maxCellVoltage,
    required this.recommendedChargeVoltage,
    required this.maxChargeCurrent,
    required this.maxDischargeCurrent,
    required this.minChargeTemperature,
    required this.maxChargeTemperature,
    required this.minDischargeTemperature,
    required this.maxDischargeTemperature,
    required this.cellDeltaOkThresholdMv,
    required this.cellDeltaWarningThresholdMv,
    required this.cellDeltaCriticalThresholdMv,
    required this.expectedCycleLife,
  });

  final String id;
  final String name;
  final BatteryChemistry chemistry;
  final int seriesCellCount;
  final double nominalVoltage;
  final double nominalCapacityAh;
  final double minCellVoltage;
  final double maxCellVoltage;
  final double recommendedChargeVoltage;
  final double maxChargeCurrent;
  final double maxDischargeCurrent;
  final double minChargeTemperature;
  final double maxChargeTemperature;
  final double minDischargeTemperature;
  final double maxDischargeTemperature;
  final double cellDeltaOkThresholdMv;
  final double cellDeltaWarningThresholdMv;
  final double cellDeltaCriticalThresholdMv;
  final int expectedCycleLife;

  double get cellDeltaOkThresholdV => cellDeltaOkThresholdMv / 1000;
  double get cellDeltaWarningThresholdV => cellDeltaWarningThresholdMv / 1000;
  double get cellDeltaCriticalThresholdV => cellDeltaCriticalThresholdMv / 1000;

  Map<String, dynamic> toBmsJson({
    String? modelName,
    String? firmwareVersion,
  }) {
    return {
      'profileName': name,
      'chemistry': chemistry.name,
      'seriesCellCount': seriesCellCount,
      'nominalVoltage': nominalVoltage,
      'nominalCapacityAh': nominalCapacityAh,
      'modelName': modelName,
      'firmwareVersion': firmwareVersion,
      'limits': {
        'maxChargeCurrent': maxChargeCurrent,
        'maxDischargeCurrent': maxDischargeCurrent,
        'minChargeTemperature': minChargeTemperature,
        'maxChargeTemperature': maxChargeTemperature,
        'minDischargeTemperature': minDischargeTemperature,
        'maxDischargeTemperature': maxDischargeTemperature,
        'minCellVoltage': minCellVoltage,
        'maxCellVoltage': maxCellVoltage,
        'recommendedChargeVoltage': recommendedChargeVoltage,
      },
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'createdBy': 'INNPO Smart Battery',
    };
  }

  factory BatteryProfile.fromBmsJson(Map<String, dynamic> json) {
    final limits = (json['limits'] as Map?)?.cast<String, dynamic>() ?? const {};
    final chemistryName = json['chemistry'] as String? ?? 'unknown';
    final seriesCellCount = (json['seriesCellCount'] as num?)?.toInt() ?? 4;
    final nominalVoltage = (json['nominalVoltage'] as num?)?.toDouble() ?? 12.8;
    final nominalCapacityAh =
        (json['nominalCapacityAh'] as num?)?.toDouble() ?? 100;
    return BatteryProfile(
      id: _stableId(json['profileName'] as String? ?? 'imported-bms-profile'),
      name: json['profileName'] as String? ?? 'Imported BMS Profile',
      chemistry: BatteryChemistry.values.firstWhere(
        (item) => item.name == chemistryName,
        orElse: () => BatteryChemistry.unknown,
      ),
      seriesCellCount: seriesCellCount,
      nominalVoltage: nominalVoltage,
      nominalCapacityAh: nominalCapacityAh,
      minCellVoltage: (limits['minCellVoltage'] as num?)?.toDouble() ?? 2.5,
      maxCellVoltage: (limits['maxCellVoltage'] as num?)?.toDouble() ?? 3.65,
      recommendedChargeVoltage:
          (limits['recommendedChargeVoltage'] as num?)?.toDouble() ??
              nominalVoltage * 1.14,
      maxChargeCurrent:
          (limits['maxChargeCurrent'] as num?)?.toDouble() ?? 50,
      maxDischargeCurrent:
          (limits['maxDischargeCurrent'] as num?)?.toDouble() ?? 100,
      minChargeTemperature:
          (limits['minChargeTemperature'] as num?)?.toDouble() ?? 0,
      maxChargeTemperature:
          (limits['maxChargeTemperature'] as num?)?.toDouble() ?? 45,
      minDischargeTemperature:
          (limits['minDischargeTemperature'] as num?)?.toDouble() ?? -20,
      maxDischargeTemperature:
          (limits['maxDischargeTemperature'] as num?)?.toDouble() ?? 60,
      cellDeltaOkThresholdMv:
          (limits['cellDeltaOkThresholdMv'] as num?)?.toDouble() ?? 20,
      cellDeltaWarningThresholdMv:
          (limits['cellDeltaWarningThresholdMv'] as num?)?.toDouble() ?? 50,
      cellDeltaCriticalThresholdMv:
          (limits['cellDeltaCriticalThresholdMv'] as num?)?.toDouble() ?? 100,
      expectedCycleLife:
          (json['expectedCycleLife'] as num?)?.toInt() ?? 2000,
    );
  }

  factory BatteryProfile.fromBatteryData(BatteryData battery) {
    final model = battery.modelName?.toLowerCase() ?? '';
    if (model.contains('golf')) {
      return BatteryProfiles.golfCart51v100ah;
    }
    if (battery.cells.length >= 16 || battery.totalVoltage >= 48) {
      return BatteryProfiles.lifepo4_51v100ah_16s;
    }
    if (battery.cells.length >= 8 || battery.totalVoltage >= 24) {
      return BatteryProfiles.lifepo4_25v100ah_8s;
    }
    if (battery.cells.length >= 4 || battery.totalVoltage >= 12) {
      return BatteryProfiles.lifepo4_12v100ah_4s;
    }
    return BatteryProfiles.genericBms;
  }
}

String _stableId(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

abstract final class BatteryProfiles {
  static const lifepo4_12v100ah_4s = BatteryProfile(
    id: 'lifepo4-12v8-100ah-4s',
    name: 'LiFePO4 12.8V 100Ah 4S',
    chemistry: BatteryChemistry.lifepo4,
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
    expectedCycleLife: 4000,
  );

  static const lifepo4_25v100ah_8s = BatteryProfile(
    id: 'lifepo4-25v6-100ah-8s',
    name: 'LiFePO4 25.6V 100Ah 8S',
    chemistry: BatteryChemistry.lifepo4,
    seriesCellCount: 8,
    nominalVoltage: 25.6,
    nominalCapacityAh: 100,
    minCellVoltage: 2.5,
    maxCellVoltage: 3.65,
    recommendedChargeVoltage: 29.2,
    maxChargeCurrent: 50,
    maxDischargeCurrent: 100,
    minChargeTemperature: 0,
    maxChargeTemperature: 45,
    minDischargeTemperature: -20,
    maxDischargeTemperature: 60,
    cellDeltaOkThresholdMv: 20,
    cellDeltaWarningThresholdMv: 50,
    cellDeltaCriticalThresholdMv: 100,
    expectedCycleLife: 4000,
  );

  static const lifepo4_51v100ah_16s = BatteryProfile(
    id: 'lifepo4-51v2-100ah-16s',
    name: 'LiFePO4 51.2V 100Ah 16S',
    chemistry: BatteryChemistry.lifepo4,
    seriesCellCount: 16,
    nominalVoltage: 51.2,
    nominalCapacityAh: 100,
    minCellVoltage: 2.5,
    maxCellVoltage: 3.65,
    recommendedChargeVoltage: 58.4,
    maxChargeCurrent: 50,
    maxDischargeCurrent: 100,
    minChargeTemperature: 0,
    maxChargeTemperature: 45,
    minDischargeTemperature: -20,
    maxDischargeTemperature: 60,
    cellDeltaOkThresholdMv: 20,
    cellDeltaWarningThresholdMv: 50,
    cellDeltaCriticalThresholdMv: 100,
    expectedCycleLife: 4000,
  );

  static const golfCart51v100ah = BatteryProfile(
    id: 'golf-cart-51v2-100ah',
    name: 'Golf Cart 51.2V 100Ah',
    chemistry: BatteryChemistry.lifepo4,
    seriesCellCount: 16,
    nominalVoltage: 51.2,
    nominalCapacityAh: 100,
    minCellVoltage: 2.5,
    maxCellVoltage: 3.65,
    recommendedChargeVoltage: 58.4,
    maxChargeCurrent: 50,
    maxDischargeCurrent: 200,
    minChargeTemperature: 0,
    maxChargeTemperature: 45,
    minDischargeTemperature: -20,
    maxDischargeTemperature: 60,
    cellDeltaOkThresholdMv: 20,
    cellDeltaWarningThresholdMv: 50,
    cellDeltaCriticalThresholdMv: 100,
    expectedCycleLife: 3500,
  );

  static const solarStorage51v = BatteryProfile(
    id: 'solar-storage-51v2',
    name: 'Solar Storage 51.2V',
    chemistry: BatteryChemistry.lifepo4,
    seriesCellCount: 16,
    nominalVoltage: 51.2,
    nominalCapacityAh: 100,
    minCellVoltage: 2.5,
    maxCellVoltage: 3.65,
    recommendedChargeVoltage: 56.8,
    maxChargeCurrent: 50,
    maxDischargeCurrent: 100,
    minChargeTemperature: 0,
    maxChargeTemperature: 45,
    minDischargeTemperature: -20,
    maxDischargeTemperature: 60,
    cellDeltaOkThresholdMv: 20,
    cellDeltaWarningThresholdMv: 50,
    cellDeltaCriticalThresholdMv: 100,
    expectedCycleLife: 6000,
  );

  static const genericBms = BatteryProfile(
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

  static const initialProfiles = [
    lifepo4_12v100ah_4s,
    lifepo4_25v100ah_8s,
    lifepo4_51v100ah_16s,
    golfCart51v100ah,
    solarStorage51v,
    genericBms,
  ];

  static BatteryProfile byId(String id) {
    return initialProfiles.firstWhere(
      (profile) => profile.id == id,
      orElse: () => genericBms,
    );
  }
}
