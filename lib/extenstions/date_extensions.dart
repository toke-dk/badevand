import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

extension DateExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday => onlyYearMonthDay == DateTime.now().onlyYearMonthDay;

  DateTime get onlyYearMonthDay => DateTime(year, month, day);

  String get myDateFormat => DateFormat("dd-MM-yyyy").format(this);

  String get meteoDateFormat => '${DateFormat("yyyy-MM-dd").format(this.onlyYearMonthDay)}T00:00:00Z';

  String get stringAsDayName => DateFormat.E("da").format(this);

  String get dateAsRelativeString {
    final now = DateTime.now();
    if (isSameDate(now)) {
      return 'I dag';
    } else if (difference(now.onlyYearMonthDay).inDays == 1) {
      return 'I morgen';
    } else {
      return stringAsDayName;
    }
  }
}
