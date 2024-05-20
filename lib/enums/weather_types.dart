import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

enum WeatherTypes {
  sunny,
  lightSun,
  partlyCloudy,
  cloudy,
  partlyRainPeriodsWithSun,
  partlyThunderPeriodsWithSun,
  someRainOrSleetPeriodsWithSun,
  someSnowPeriodsWithSun,
  lightRain,
  rain,
  thunderAndRain,
  sleet,
  snow,
  thunderAndSnow,
  fog,
  unknown,
}

extension WeatherTypesExtension on WeatherTypes {
  String get displayedText {
    switch (this) {
      case WeatherTypes.sunny:
        return "Solskin";
      case WeatherTypes.lightSun:
        return "Let skyet";
      case WeatherTypes.partlyCloudy:
        return "Halvskyet";
      case WeatherTypes.cloudy:
        return "Skyet";
      case WeatherTypes.partlyRainPeriodsWithSun:
        return "Enkelte regnbyer, perioder med sol";
      case WeatherTypes.partlyThunderPeriodsWithSun:
        return "Enkelte tordenbyger, perioder med sol";
      case WeatherTypes.someRainOrSleetPeriodsWithSun:
        return "Nogen regn eller slud, perioder med sol";
      case WeatherTypes.someSnowPeriodsWithSun:
        return "Nogen sne, perioder med sol";
      case WeatherTypes.lightRain:
        return "Let regn";
      case WeatherTypes.rain:
        return "Regn";
      case WeatherTypes.thunderAndRain:
        return "Torden og regn";
      case WeatherTypes.sleet:
        return "Slud";
      case WeatherTypes.snow:
        return "Sne";
      case WeatherTypes.thunderAndSnow:
        return "Torden og sne";
      case WeatherTypes.fog:
        return "Toget";
      case WeatherTypes.unknown:
        return "Ukendt vejr";
    }
  }

  Widget get icon {
    switch (this) {
      case WeatherTypes.sunny:
        return Icon(
          WeatherIcons.day_sunny,
          color: Colors.amber[800],
        );
      case WeatherTypes.lightSun:
        return const Icon(WeatherIcons.day_sunny_overcast);
      case WeatherTypes.partlyCloudy:
        return const Icon(WeatherIcons.day_cloudy);
      case WeatherTypes.cloudy:
        return const Icon(WeatherIcons.cloud);
      case WeatherTypes.partlyRainPeriodsWithSun:
        return const Icon(WeatherIcons.day_rain);
      case WeatherTypes.partlyThunderPeriodsWithSun:
        return const Icon(WeatherIcons.day_thunderstorm);
      case WeatherTypes.someRainOrSleetPeriodsWithSun:
        return const Icon(WeatherIcons.day_sleet);
      case WeatherTypes.someSnowPeriodsWithSun:
        return const Icon(WeatherIcons.day_snow);
      case WeatherTypes.lightRain:
        return Icon(
          WeatherIcons.rain,
          color: Colors.blue[800],
        );
      case WeatherTypes.rain:
        return Icon(
          WeatherIcons.rain,
          color: Colors.blue[800],
        );
      case WeatherTypes.thunderAndRain:
        return const Icon(WeatherIcons.thunderstorm);
      case WeatherTypes.sleet:
        return const Icon(WeatherIcons.sleet);
      case WeatherTypes.snow:
        return const Icon(WeatherIcons.snow);

      case WeatherTypes.thunderAndSnow:
        return const Icon(WeatherIcons.snow);

      case WeatherTypes.fog:
        return const Icon(WeatherIcons.fog);
      case WeatherTypes.unknown:
        return const Icon(Icons.question_mark);

    }
  }
}

WeatherTypes? convertIntToWeatherType(int value) {
  if (value < 1) {
    throw ArgumentError(
        'Number must be between 1 and ${WeatherTypes.values.length}');
  }
  else if (value > WeatherTypes.values.length) {
    return WeatherTypes.unknown;
  }
  return WeatherTypes.values[value - 1];
}
