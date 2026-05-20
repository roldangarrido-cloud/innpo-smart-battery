import 'alarm_data.dart';
import 'bms_device.dart';
import 'cell_data.dart';
import 'temperature_sensor_data.dart';

export 'alarm_data.dart';
export 'bms_device.dart';
export 'cell_data.dart';
export 'temperature_sensor_data.dart';

enum BatteryOperationStatus {
  charging,
  discharging,
  idle,
  full,
  protection,
  unknown,
}

enum BatteryConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class BatteryData {
  const BatteryData({
    required this.deviceId,
    required this.deviceName,
    required this.serialNumber,
    required this.modelName,
    required this.firmwareVersion,
    required this.timestamp,
    required this.totalVoltage,
    required this.current,
    required this.power,
    required this.socPercent,
    required this.sohPercent,
    required this.remainingCapacityAh,
    required this.nominalCapacityAh,
    required this.cycleCount,
    required this.operationStatus,
    required this.temperatures,
    required this.cells,
    required this.minCellVoltage,
    required this.maxCellVoltage,
    required this.cellVoltageDelta,
    required this.minCellIndex,
    required this.maxCellIndex,
    required this.isBalancing,
    required this.balancingCellIndexes,
    required this.chargeMosfetEnabled,
    required this.dischargeMosfetEnabled,
    required this.activeAlarms,
    this.historicalAlarms = const [],
    required this.rssi,
    required this.isConnected,
  });

  final String deviceId;
  final String deviceName;
  final String? serialNumber;
  final String? modelName;
  final String? firmwareVersion;
  final DateTime timestamp;

  final double totalVoltage;
  final double current;
  final double power;
  final double socPercent;
  final double? sohPercent;
  final double remainingCapacityAh;
  final double nominalCapacityAh;
  final int cycleCount;

  final BatteryOperationStatus operationStatus;

  final List<TemperatureSensorData> temperatures;

  final List<CellData> cells;
  final double minCellVoltage;
  final double maxCellVoltage;
  final double cellVoltageDelta;
  final int? minCellIndex;
  final int? maxCellIndex;

  final bool isBalancing;
  final List<int> balancingCellIndexes;

  final bool chargeMosfetEnabled;
  final bool dischargeMosfetEnabled;

  final List<AlarmData> activeAlarms;
  final List<AlarmData> historicalAlarms;

  final int? rssi;
  final bool isConnected;

  bool get hasCriticalAlarm {
    return activeAlarms.any(
      (alarm) => alarm.active && alarm.severity == AlarmSeverity.critical,
    );
  }

  bool get hasWarning {
    return activeAlarms.any(
      (alarm) => alarm.active && alarm.severity == AlarmSeverity.warning,
    );
  }

  bool get isHealthy {
    return isConnected &&
        !hasCriticalAlarm &&
        !hasWarning &&
        operationStatus != BatteryOperationStatus.protection;
  }

  double get averageCellVoltage {
    if (cells.isEmpty) {
      return 0;
    }
    final total = cells.fold<double>(0, (sum, cell) => sum + cell.voltage);
    return total / cells.length;
  }

  String get formattedVoltage => '${totalVoltage.toStringAsFixed(2)} V';
  String get formattedCurrent => '${current.toStringAsFixed(1)} A';
  String get formattedPower => '${power.toStringAsFixed(0)} W';

  // Compatibility getters for older presentation code during migration.
  String get id => deviceId;
  String get name => deviceName;
  String get model => modelName ?? 'Unknown model';
  double get voltage => totalVoltage;
  int get soc => socPercent.round();
  int get soh => sohPercent?.round() ?? 0;
  double get temperatureMin => temperatures.isEmpty
      ? 0
      : temperatures
          .map((sensor) => sensor.celsius)
          .reduce((a, b) => a < b ? a : b);
  double get temperatureMax => temperatures.isEmpty
      ? 0
      : temperatures
          .map((sensor) => sensor.celsius)
          .reduce((a, b) => a > b ? a : b);
  bool get chargeMosEnabled => chargeMosfetEnabled;
  bool get dischargeMosEnabled => dischargeMosfetEnabled;
  bool get balancingActive => isBalancing;
  List<AlarmData> get alarms => activeAlarms;
  BatteryConnectionState get connectionState => isConnected
      ? BatteryConnectionState.connected
      : BatteryConnectionState.disconnected;
  BatteryOperationStatus get operatingState => operationStatus;
  double get cellDelta => cellVoltageDelta;
  DateTime get lastUpdatedAt => timestamp;
}

class BleBatteryDevice extends BmsDevice {
  const BleBatteryDevice({
    required super.id,
    required super.name,
    super.rssi,
    required this.isInnpoCandidate,
    super.localName,
    super.manufacturerName,
    super.isFavorite,
    super.lastConnectedAt,
    super.batteryAlias,
    super.batteryModel,
    super.serialNumber,
  });

  final bool isInnpoCandidate;
}

typedef BatteryStatus = BatteryData;
typedef BatteryOperatingState = BatteryOperationStatus;
