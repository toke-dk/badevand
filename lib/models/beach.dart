
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/wind_direction.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../enums/water_quality.dart';
import '../providers/beaches_provider.dart';

class Beach {
  String id;
  String name;
  String? description;
  String? comments;
  List<BeachSpecifications> beachSpecifications;
  LatLng position;
  String municipality;
  bool isFavourite;

  Beach({
    required this.id,
    required this.name,
    this.description,
    this.comments,
    this.beachSpecifications = const [],
    required this.position,
    required this.municipality,
    this.isFavourite = false,
  });

  factory Beach.fromMap(Map<String, dynamic> map, bool isBeachFavourite) {
    return Beach(
      id: map["id"].toString(),
      name: map["name"] as String,
      description: map["description"] as String?,
      comments: map["comments"]?.toString(),
      beachSpecifications: (map["data"] as List<dynamic>)
          .map((dataMap) => BeachSpecifications.fromMap(dataMap))
          .toList(),
      position: LatLng(double.parse(map["latitude"].toString()),
          double.parse(map["longitude"].toString())),
      municipality: map["municipality"].toString(),
      isFavourite: isBeachFavourite,
    );
  }

  BeachSpecifications? get getSpecsOfToday {
    if (beachSpecifications.indexWhere((specs) => specs.dataDate.isToday) == -1)
      return null;

    return beachSpecifications
        .firstWhere((element) => element.dataDate.isToday);
  }

  Widget createFavoriteIcon(BuildContext context, {Color? color}) => IconButton(
        onPressed: () {
          context.read<BeachesProvider>().changeValueFavoriteBeach(this);
        },
        icon: Icon(
          isFavourite ? Icons.star : Icons.star_outline,
          color: color ?? Colors.yellow[600],
          size: 30,
        ),
      );

  int? distanceInKm(LatLng? userPosition) {
    if (userPosition == null) return null;
    return (Geolocator.distanceBetween(userPosition.latitude,
                userPosition.longitude, position.latitude, position.longitude) /
            1000)
        .toInt();
  }
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
