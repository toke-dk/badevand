extension DateExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday => onlyYearMonthDay == DateTime.now().onlyYearMonthDay;

  DateTime get onlyYearMonthDay => DateTime(year, month, day);
}