import 'package:intl/intl.dart';

findPreviousFriday(DateTime dateTime) {
  int daysToSubtract = (dateTime.weekday + 1) % 7 + 1;
  return dateTime.subtract(Duration(days: daysToSubtract));
}

