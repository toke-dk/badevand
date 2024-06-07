import 'package:badevand/models/meteo/weather_data.dart';
import 'package:badevand/models/meteo/weather_type.dart';

class DailyForecastMeteoData {
  DateTime dateToForecast;
  double precipitation24h;
  int weatherIdx24h;

  DailyForecastMeteoData(
      {required this.dateToForecast,
      required this.precipitation24h,
      required this.weatherIdx24h});

  WeatherType get getWeatherType => WeatherType(weatherIndex: weatherIdx24h);
}

List<DailyForecastMeteoData> getDailyMeteorologicalDataList(List<dynamic> map) {
  List<DailyForecastMeteoData> dataList = [];
  for (int i = 0; i < getDates(map).length; i++) {
    dataList.add(DailyForecastMeteoData(
        dateToForecast: getDates(map)[i],
        precipitation24h: getDatesInfoFromString(map, "precip_24h:mm")[i],
        weatherIdx24h:
            getDatesInfoFromString(map, "weather_symbol_24h:idx")[i].toInt()));
  }

  return dataList;
}
