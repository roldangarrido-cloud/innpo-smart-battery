import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static String formatDateTime(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm').format(value);
  }
}

