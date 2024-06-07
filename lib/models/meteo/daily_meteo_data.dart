import 'package:badevand/models/meteo/weather_data.dart';
import 'package:badevand/models/meteo/weather_type.dart';

class DailyMeteoData {
  DateTime date;
  double precipitation24h;
  int weatherIdx24h;

  DailyMeteoData(
      {required this.date,
      required this.precipitation24h,
      required this.weatherIdx24h});

  WeatherType get getWeatherType => WeatherType(weatherIndex: weatherIdx24h);
}

List<DailyMeteoData> getDailyMeteorologicalDataList(List<dynamic> map) {
  List<DailyMeteoData> dataList = [];
  for (int i = 0; i < getDates(map).length; i++) {
    dataList.add(DailyMeteoData(
        date: getDates(map)[i],
        precipitation24h: getDatesInfoFromString(map, "precip_24h:mm")[i],
        weatherIdx24h:
            getDatesInfoFromString(map, "weather_symbol_24h:idx")[i].toInt()));
  }

  return dataList;
}
