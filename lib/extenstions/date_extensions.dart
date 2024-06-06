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

  String get myTimeFormat => DateFormat("HH:mm").format(this);

  String get meteoDateFormat => "${DateFormat('yyyy-MM-ddTHH:mm:ss').format(this.onlyYearMonthDay)}Z";

  String get meteoDateFormatHour => "${DateFormat('yyyy-MM-ddTHH:mm:ss').format(this.onlyYMDH)}Z";

  String get stringAsDayName => DateFormat.E("da").format(this);

  DateTime get onlyYMDH {
    return DateTime(year, month, day, hour);
  }

  DateTime get toNearestHour {
    return DateTime(year, month, day, minute >= 30 ? hour + 1 : hour);
  }

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
