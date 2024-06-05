import 'package:badevand/models/meteo/date_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeteorologicalData {
  List<DateInfo> temperatures;
  List<DateInfo> precipitation;
  List<DateInfo> windSpeeds;
  List<DateInfo> windGusts;
  List<DateInfo> windDirections;
  List<DateInfo> uvIndexes;
  List<DateInfo> weatherSymbols;

  MeteorologicalData(
      {required this.temperatures,
      required this.precipitation,
      required this.windSpeeds,
      required this.windGusts,
      required this.windDirections,
      required this.uvIndexes,
      required this.weatherSymbols});

  factory MeteorologicalData.fromMeteoMap(List<dynamic> map) {
    List<DateInfo> getDatesInfoFromString(String string) {
      return (map
              .firstWhere((e) => e["parameter"] == string)["coordinates"]
              .first["dates"] as List<dynamic>)
          .map((m) => DateInfo.fromMap(m))
          .toList();
    }

    return MeteorologicalData(
        temperatures: getDatesInfoFromString("t_2m:C"),
        precipitation: getDatesInfoFromString("precip_1h:mm"),
        windSpeeds: getDatesInfoFromString("wind_speed_10m:ms"),
        windGusts: getDatesInfoFromString("wind_gusts_10m_1h:ms"),
        windDirections: getDatesInfoFromString("wind_dir_10m:d"),
        uvIndexes: getDatesInfoFromString("uv:idx"),
        weatherSymbols: getDatesInfoFromString("weather_symbol_1h:idx"));
  }
}
