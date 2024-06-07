import 'package:badevand/models/meteo/weather_type.dart';

class MeteorologicalData {
  DateTime date;
  double temperature;
  double precipitation;
  double windSpeed;
  double windGust;
  double windDirection;
  double uvIndex;
  int weatherIdx;

  MeteorologicalData(
      {required this.date,
      required this.temperature,
      required this.precipitation,
      required this.windSpeed,
      required this.windGust,
      required this.windDirection,
      required this.uvIndex,
      required this.weatherIdx});

  WeatherType get getWeatherType => WeatherType(weatherIndex: weatherIdx);
}

List<MeteorologicalData> getMeteorologicalDataList(List<dynamic> map) {

  List<MeteorologicalData> dataList = [];
  for (int i = 0; i < getDates(map).length; i++) {
    dataList.add(MeteorologicalData(
        date: getDates(map)[i],
        temperature: getDatesInfoFromString(map, "t_2m:C")[i],
        precipitation: getDatesInfoFromString(map, "precip_1h:mm")[i],
        windSpeed: getDatesInfoFromString(map, "wind_speed_10m:ms")[i],
        windGust: getDatesInfoFromString(map, "wind_gusts_10m_1h:ms")[i],
        windDirection: getDatesInfoFromString(map, "wind_dir_10m:d")[i],
        uvIndex: getDatesInfoFromString(map, "uv:idx")[i],
        weatherIdx:
            getDatesInfoFromString(map, "weather_symbol_1h:idx")[i].toInt()));
  }

  return dataList;
}

List<double> getDatesInfoFromString(List<dynamic> map, String string) {
  return (map
      .firstWhere((e) => e["parameter"] == string)["coordinates"]
      .first["dates"] as List<dynamic>)
      .map((m) => double.parse(m["value"].toString()))
      .toList();
}

List<DateTime> getDates(List<dynamic> map) {
  return (map.first["coordinates"].first["dates"] as List<dynamic>)
      .map((m) => DateTime.parse(m["date"].toString()).toLocal())
      .toList();
}