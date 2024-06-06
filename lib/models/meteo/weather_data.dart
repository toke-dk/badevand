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

  Image weatherSymbolImage({double? scale}) => Image.asset(
        "assets/weather_symbols/${weatherIdx}.png",
        scale: scale,
      );

  String get weatherDescription {
    if (weatherIdx < 0 || weatherIdx > 116) {
      return "Fejl i beskrivelse";
    }
    final index = weatherIdx % 100;

    final List<String> descriptions = [
      "Et vejrsymbol kunne ikke bestemmes",
      "Skyfri himmel",
      "Lette skyer",
      "Delvist skyet",
      "Overskyet",
      "Regn",
      "Regn og sne / slud",
      "Sne",
      "Regnbyge",
      "Snebyge",
      "Sludbyge",
      "Let tåge",
      "Tyk tåge",
      "Frysende regn",
      "Tordenvejr",
      "Støvregn",
      "Sandstorm"
    ];

    return descriptions[index];
  }
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
        .map((m) => DateTime.parse(m["date"].toString()).toLocal())
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
        weatherIdx:
            getDatesInfoFromString("weather_symbol_1h:idx")[i].toInt()));
  }

  return dataList;
}
