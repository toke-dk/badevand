import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/meteo/weather_data.dart';
import 'daily_meteo_data.dart';

class DayGroupedMeteorologicalData {
  DateTime day;
  List<MeteorologicalData> dataList;
  DailyForecastMeteoData? dailyForeCast;

  DayGroupedMeteorologicalData(
      {required this.day, required this.dataList, required this.dailyForeCast});
}

List<DayGroupedMeteorologicalData> groupMeteoData(List<MeteorologicalData> meteorologicalDataList,
    List<DailyForecastMeteoData> dailyData) {
  List<DayGroupedMeteorologicalData> groups = [];
  for (final idxData in meteorologicalDataList) {
    final DateTime dateDay = idxData.date.onlyYearMonthDay;
    final int index = groups.indexWhere((g) => g.day == dateDay);
    // not found
    if (index == -1) {
      // make a new date

      final int dayForecastIndex = dailyData
          .indexWhere((d) => d.dateToForecast.onlyYearMonthDay == dateDay);

      groups.add(DayGroupedMeteorologicalData(
          day: dateDay,
          dataList: [idxData],
          dailyForeCast:
              dayForecastIndex == -1 ? null : dailyData[dayForecastIndex]));
    } else {
      // add the data to the date
      groups[index].dataList.add(idxData);
    }
  }
  return groups;
}
