import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

enum WeatherTypes {sunny, lightSun, partlyCloudy, cloudy, partlyRainPeriodsWithSun, partlyThunderPeriodsWithSun, someRainOrSleetPeriodsWithSun, someSnowPeriodsWithSun, lightRain, rain, thunderAndRain, sleet, snow, thunderAndSnow, fog}

extension WeatherTypesExtension on WeatherTypes {
  Widget get icon {

    switch (this) {
      case WeatherTypes.sunny:
        return Icon(WeatherIcons.day_sunny, color: Colors.amber[800],);
      case WeatherTypes.lightSun:
        return Icon(WeatherIcons.day_sunny_overcast);
      case WeatherTypes.partlyCloudy:
        return Icon(WeatherIcons.day_cloudy);
      case WeatherTypes.cloudy:
        return Icon(WeatherIcons.cloud);
      case WeatherTypes.partlyRainPeriodsWithSun:
        return Icon(WeatherIcons.day_rain);

      case WeatherTypes.partlyThunderPeriodsWithSun:
        return Icon(WeatherIcons.day_thunderstorm);
      case WeatherTypes.someRainOrSleetPeriodsWithSun:
        return Icon(WeatherIcons.day_sleet);
      case WeatherTypes.someSnowPeriodsWithSun:
        return Icon(WeatherIcons.day_snow);
      case WeatherTypes.lightRain:
        return Icon(WeatherIcons.rain, color: Colors.blue[800],);

      case WeatherTypes.rain:
        return Icon(WeatherIcons.rain, color: Colors.blue[800],);
      case WeatherTypes.thunderAndRain:
        return Icon(WeatherIcons.thunderstorm);
      case WeatherTypes.sleet:
        return Icon(WeatherIcons.sleet);
      case WeatherTypes.snow:
        return Icon(WeatherIcons.snow);

      case WeatherTypes.thunderAndSnow:
        return Icon(WeatherIcons.snow);

      case WeatherTypes.fog:
        return Icon(WeatherIcons.fog);
    }
  }
}

WeatherTypes? convertIntToWeatherType(int value) {
  if (value < 1 || value > WeatherTypes.values.length) {
    throw ArgumentError('Number must be between 1 and ${WeatherTypes.values.length}');
  }
  return WeatherTypes.values[value-1];
}