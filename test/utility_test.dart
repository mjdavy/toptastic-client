

import 'package:flutter_test/flutter_test.dart';
import 'package:toptastic/models/utility.dart';

void main() {
  group('findPreviousFriday', () {
    test('returns previous Friday when the day is Monday', () {
      DateTime input = DateTime(2023, 12, 18); // a Monday
      DateTime expectedOutput = DateTime(2023, 12, 15); // the previous Friday
      expect(findPreviousFriday(input), expectedOutput);
    });

    test('returns previous Friday when the day is Friday', () {
      DateTime input = DateTime(2023, 12, 15); // a Friday
      DateTime expectedOutput = DateTime(2023, 12, 8); // the previous Friday
      expect(findPreviousFriday(input), expectedOutput);
    });

    // Add more tests for other cases if needed
  });
}