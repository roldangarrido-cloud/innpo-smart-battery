class NumberFormatUtils {
  const NumberFormatUtils._();

  static String volts(double value) => '${value.toStringAsFixed(2)} V';
  static String amps(double value) => '${value.toStringAsFixed(1)} A';
  static String watts(double value) => '${value.toStringAsFixed(0)} W';
  static String percent(num value) => '${value.toStringAsFixed(0)}%';
}

