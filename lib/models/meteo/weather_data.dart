import 'package:badevand/models/meteo/date_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeteorologicalData {
  DateTime date;
  double temperature;
  double precipitation;
  double windSpeed;
  double windGust;
  double windDirection;
  double uvIndex;
  int weatherSymbolIdx;

  MeteorologicalData(
      {required this.date,
      required this.temperature,
      required this.precipitation,
      required this.windSpeed,
      required this.windGust,
      required this.windDirection,
      required this.uvIndex,
      required this.weatherSymbolIdx});

  Widget get weatherSymbolImage => Image.asset("assets/weather_symbols/${weatherSymbolIdx}.png");
}

List<MeteorologicalData> getMeteorologicalDataList(List<dynamic> map) {
  List<double> getDatesInfoFromString(String string) {
    return (map
            .firstWhere((e) => e["parameter"] == string)["coordinates"]
            .first["dates"] as List<dynamic>)
        .map((m) => double.parse(m["value"].toString()))
        .toList();
  }

  List<DateTime> getDates() {
    return (map.first["coordinates"].first["dates"] as List<dynamic>)
        .map((m) => DateTime.parse(m["date"].toString()))
        .toList();
  }

  List<MeteorologicalData> dataList = [];
  for (int i = 0; i < getDates().length; i++) {
    dataList.add(MeteorologicalData(
        date: getDates()[i],
        temperature: getDatesInfoFromString("t_2m:C")[i],
        precipitation: getDatesInfoFromString("precip_1h:mm")[i],
        windSpeed: getDatesInfoFromString("wind_speed_10m:ms")[i],
        windGust: getDatesInfoFromString("wind_gusts_10m_1h:ms")[i],
        windDirection: getDatesInfoFromString("wind_dir_10m:d")[i],
        uvIndex: getDatesInfoFromString("uv:idx")[i],
        weatherSymbolIdx: getDatesInfoFromString("weather_symbol_1h:idx")[i].toInt()));
  }

  return dataList;
}
