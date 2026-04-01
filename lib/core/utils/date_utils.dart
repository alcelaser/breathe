class RecoveryDateUtils {
  static String toIsoDate(DateTime date) {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String();
  }
}
