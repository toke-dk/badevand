import '../../enums/water_quality.dart';
import '../../enums/weather_types.dart';
import '../wind_direction.dart';

class DhiBeachSpecifications {
  DateTime dataDate;
  WaterQualityTypes waterQualityType;
  double waterTemperature;
  double airTemperature;
  WeatherTypes? weatherType;
  double? windSpeed;
  WindDirection? windDirection;
  double? precipitation;

  DhiBeachSpecifications({
    required this.dataDate,
    required this.waterQualityType,
    required this.waterTemperature,
    required this.airTemperature,
    required this.weatherType,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitation,
  });

  factory DhiBeachSpecifications.fromMap(Map<String, dynamic> map) {
    return DhiBeachSpecifications(
        dataDate: DateTime.parse(map["date"].toString()),
        waterQualityType: convertIntToQualityType(
            int.parse(map["water_quality"].toString()))!,
        waterTemperature: double.parse(map["water_temperature"].toString()),
        airTemperature: double.parse(map["air_temperature"].toString()),
        weatherType:
        convertIntToWeatherType(int.parse(map["weather_type"].toString()))!,
        windSpeed: map["wind_speed"].toString() == ""
            ? null
            : double.parse(map["wind_speed"].toString()),
        windDirection: map["wind_direction"].toString() == ""
            ? null
            : WindDirection(
            angle: double.parse(map["wind_direction"].toString())),
        precipitation: map["precipitation"].toString() == ""
            ? null
            : double.parse(map["precipitation"].toString()));
  }
}