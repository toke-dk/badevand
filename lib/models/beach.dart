import 'dart:convert';

import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_icons/weather_icons.dart';

import '../enums/water_quality.dart';

class Beach {
  int id;
  String name;
  String? description;
  String? comments;
  List<BeachSpecifications> beachSpecifications;
  LatLng position;

  Beach({
    required this.id,
    required this.name,
    required this.description,
    required this.comments,
    required this.beachSpecifications,
    required this.position,
  });

  factory Beach.fromMap(Map<String, dynamic> map) {
    print("beachname: ${map["name"] as String}");
    return Beach(
      id: int.parse(map["id"].toString()),
      name: map["name"] as String,
      description: map["description"] as String?,
      comments: map["comments"]?.toString(),
      beachSpecifications: (map["data"] as List<dynamic>)
          .map((dataMap) => BeachSpecifications.fromMap(dataMap))
          .toList(),
      position: LatLng(double.parse(map["latitude"].toString()),
          double.parse(map["longitude"].toString())),
    );
  }

  BeachSpecifications get getSpecsOfToday =>
      beachSpecifications.firstWhere((element) => element.dataDate.isToday);
}

class BeachSpecifications {
  DateTime dataDate;
  WaterQualityTypes waterQualityType;
  double waterTemperature;
  double airTemperature;
  WeatherTypes? weatherType;
  double? windSpeed;
  WindDirection? windDirection;
  double? precipitation;

  BeachSpecifications({
    required this.dataDate,
    required this.waterQualityType,
    required this.waterTemperature,
    required this.airTemperature,
    required this.weatherType,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitation,
  });

  factory BeachSpecifications.fromMap(Map<String, dynamic> map) {
    return BeachSpecifications(
        dataDate: DateTime.parse(map["date"].toString()),
        waterQualityType: convertIntToQualityType(
            int.parse(map["water_quality"].toString()))!,
        waterTemperature: double.parse(map["water_temperature"].toString()),
        airTemperature: double.parse(map["air_temperature"].toString()),
        weatherType:
        convertIntToWeatherType(int.parse(map["weather_type"].toString()))!,
        windSpeed: map["wind_speed"].toString() == "" ? null : double.parse(
            map["wind_speed"].toString()),
        windDirection: map["wind_direction"].toString() == "" ? null : double
            .parse(map["wind_direction"].toString()).getClosestWindDirection,
        precipitation: map["precipitation"].toString() == "" ? null : double
            .parse(map["precipitation"].toString()));
  }
}

enum WindDirection {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

extension WindDirectionExtension on WindDirection {
  String get windDirectionToString {
    switch (this) {
      case WindDirection.north:
        return 'N';
      case WindDirection.northEast:
        return 'NE';
      case WindDirection.east:
        return 'E';
      case WindDirection.southEast:
        return 'SE';
      case WindDirection.south:
        return 'S';
      case WindDirection.southWest:
        return 'SW';
      case WindDirection.west:
        return 'W';
      case WindDirection.northWest:
        return 'NW';
    }
    return ''; // Shouldn't be reached
  }

  IconData get windDirectionArrow {
    switch (this) {
      case WindDirection.north:
        return WeatherIcons.direction_up;
      case WindDirection.northEast:
        return WeatherIcons.direction_up_right;
      case WindDirection.east:
        return WeatherIcons.direction_right;
      case WindDirection.southEast:
        return WeatherIcons.direction_down_right;
      case WindDirection.south:
        return WeatherIcons.direction_down;
      case WindDirection.southWest:
        return WeatherIcons.direction_down_left;
      case WindDirection.west:
        return WeatherIcons.direction_left;
      case WindDirection.northWest:
        return WeatherIcons.direction_up_left;
    }
  }
}



class Range {
  final double start;
  final double end;

  const Range(this.start, this.end);

  bool contains(double value) => value >= start && value < end;
}