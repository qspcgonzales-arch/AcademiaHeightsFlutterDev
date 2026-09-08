/// Small shared text helpers.

/// Formats a date and time as `YYYY-MM-DD HH:MM` in the device's local time.
/// Used by the Load Game and Save / Load screens.
String formatDateTime(DateTime dateTime) {
  final DateTime local = dateTime.toLocal();

  final String year = local.year.toString();
  final String month = _twoDigits(local.month);
  final String day = _twoDigits(local.day);
  final String hour = _twoDigits(local.hour);
  final String minute = _twoDigits(local.minute);

  return '$year-$month-$day $hour:$minute';
}

/// Turns 3 into "03", leaves 12 as "12".
String _twoDigits(int value) {
  if (value < 10) return '0$value';
  return '$value';
}
