import 'package:badevand/models/meteo/weather_data.dart';

class DayGroupedMeteorologicalData {
  DateTime day;
  List<MeteorologicalData> dataList;

  DayGroupedMeteorologicalData({required this.day, required this.dataList});
}