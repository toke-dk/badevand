import 'dart:math';

import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/meteo/weather_data.dart';

import '../models/meteo/day_grouped_data.dart';

extension MeteorologicalDataExtension on List<MeteorologicalData> {
  double get maxTemp => map((d) => d.temperature).reduce(max);

  double get minTemp => map((d) => d.temperature).reduce(min);
}

extension DayGroupedMeteorologicalDataExtension on DayGroupedMeteorologicalData {
  String get dataOverviewString {
    final minTemp = this.dataList.minTemp.asDegrees;
    final maxTemp = this.dataList.maxTemp.asDegrees;
    final precipitation = this.dailyForeCast?.precipitation24h.asMillimetersString ?? "";

    return "${minTemp}/${maxTemp} | ${precipitation}";
  }
}