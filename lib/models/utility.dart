DateTime findPreviousFriday(DateTime dateTime) {
  final int daysToSubtract = (dateTime.weekday + 1) % 7 + 1;
  return dateTime.subtract(Duration(days: daysToSubtract));
}
