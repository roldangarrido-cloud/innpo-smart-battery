class BmsConfiguration {
  const BmsConfiguration({
    required this.nominalCapacityAh,
    required this.seriesCellCount,
    required this.parallelCellCount,
  });

  final double nominalCapacityAh;
  final int seriesCellCount;
  final int parallelCellCount;
}

