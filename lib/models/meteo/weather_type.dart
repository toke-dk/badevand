
import 'package:flutter/material.dart';

class WeatherType {
  int weatherIndex;

  WeatherType({required this.weatherIndex});

  Image weatherSymbolImage({double? scale}) => Image.asset(
    "assets/weather_symbols/${weatherIndex}.png",
    scale: scale,
  );

  String get weatherDescription {
    if (weatherIndex < 0 || weatherIndex > 116) {
      return "Fejl i beskrivelse";
    }
    final index = weatherIndex % 100;

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