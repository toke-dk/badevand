import 'dart:math';

import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
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

  double get maxTemp => map((d) => d.temperature).reduce(max);

  double get minTemp => map((d) => d.temperature).reduce(min);

  double get totalPrecipitation =>
      map((d) => d.precipitation).reduce((a, b) => a + b);
}

extension DayGroupedMeteorologicalDataExtension on DayGroupedMeteorologicalData {
  String get dataOverviewString {
    final minTemp = this.dataList.minTemp.asDegrees;
    final maxTemp = this.dataList.maxTemp.asDegrees;
    final precipitation = dataList.totalPrecipitation.asMillimetersString;

    return "${minTemp}/${maxTemp} | ${precipitation}";
  }
}