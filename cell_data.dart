enum CellStatus {
  normal,
  high,
  low,
  warning,
  critical,
}

class CellData {
  const CellData({
    required this.index,
    required this.voltage,
    required this.isBalancing,
    required this.status,
  });

  final int index;
  final double voltage;
  final bool isBalancing;
  final CellStatus status;

  String get formattedVoltage => '${voltage.toStringAsFixed(3)} V';
  int get voltageInMillivolts => (voltage * 1000).round();

  bool get balancing => isBalancing;
}

typedef CellInfo = CellData;

