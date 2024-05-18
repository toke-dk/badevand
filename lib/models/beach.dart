import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/date_extensions.dart';

import '../enums/water_quality.dart';

class Beach {
  int id;
  String name;
  String? description;
  String? comments;
  List<BeachSpecifications> beachSpecifications;

  Beach(
      {required this.id,
      required this.name,
      required this.description,
      required this.comments,
      required this.beachSpecifications});

  factory Beach.fromMap(Map<String, dynamic> map) {
    return Beach(
        id: int.parse(map["id"].toString()),
        name: map["name"] as String,
        description: map["description"] as String?,
        comments: map["comments"]?.toString(),
        beachSpecifications: (map["data"] as List<dynamic>)
            .map((dataMap) => BeachSpecifications.fromMap(dataMap))
            .toList());
  }

  BeachSpecifications get getSpecsOfToday =>
      beachSpecifications.firstWhere((element) => element.dataDate.isToday);
}

class BeachSpecifications {
  DateTime dataDate;
  WaterQualityTypes waterQualityType;
  double waterTemperature;
  double airTemperature;
  WeatherTypes weatherType;

  BeachSpecifications({
    required this.dataDate,
    required this.waterQualityType,
    required this.waterTemperature,
    required this.airTemperature,
    required this.weatherType,
  });

  factory BeachSpecifications.fromMap(Map<String, dynamic> map) {
    return BeachSpecifications(
        dataDate: DateTime.parse(map["date"].toString()),
        waterQualityType: convertIntToQualityType(
            int.parse(map["water_quality"].toString()))!,
        waterTemperature: double.parse(map["water_temperature"].toString()),
        airTemperature: double.parse(map["air_temperature"].toString()),
        weatherType: convertIntToWeatherType(
            int.parse(map["weather_type"].toString()))!);
  }
}
