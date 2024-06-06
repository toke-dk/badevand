import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/meteo/weather_data.dart';

import '../models/meteo/day_grouped_data.dart';

extension MeteorologicalDataExtension on List<MeteorologicalData> {
  List<DayGroupedMeteorologicalData> get groupData {
    List<DayGroupedMeteorologicalData> groups = [];
    for (final idxData in this) {
      final DateTime dateDay = idxData.date.onlyYearMonthDay;
      final int index = groups.indexWhere((g) => g.day == dateDay);
      // not found
      if (index == -1) {
        // make a new date
        groups.add(
            DayGroupedMeteorologicalData(day: dateDay, dataList: [idxData]));
      } else {
        // add the data to the date
        groups[index].dataList.add(idxData);
      }
    }
    return groups;
  }
}
