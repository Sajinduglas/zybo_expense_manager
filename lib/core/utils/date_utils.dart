class AppDateUtils {
  static String monthStart() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return start.toIso8601String();
  }

  static String monthEnd() {
    final now = DateTime.now();
    // Move to the next month, then subtract 1 second to get the last moment of the current month
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    return end.toIso8601String();
  }
}
