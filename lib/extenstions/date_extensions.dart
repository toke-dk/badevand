
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

extension DateExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday => onlyYearMonthDay == DateTime.now().onlyYearMonthDay;

  DateTime get onlyYearMonthDay => DateTime(year, month, day);

  String get stringAsDayName => DateFormat.E("da").format(this);
}
