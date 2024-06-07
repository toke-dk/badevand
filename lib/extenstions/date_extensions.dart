import 'package:badevand/extenstions/string_extension.dart';
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday => onlyYearMonthDay == DateTime.now().onlyYearMonthDay;

  DateTime get onlyYearMonthDay => DateTime(year, month, day);

  String get myDateFormat => DateFormat("dd-MM-yyyy").format(this);

  String get myTimeFormat => DateFormat("HH:mm").format(this);

  String get _formatInMeteo => this.toUtc().toString().replaceAll(" ", "T");

  String get meteoDateFormat => this.onlyYearMonthDay._formatInMeteo;

  String get meteoDateFormatHour => this.onlyYMDH._formatInMeteo;

  String get stringAsDayName => DateFormat.MMMEd("da").format(this).capitalize;

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
