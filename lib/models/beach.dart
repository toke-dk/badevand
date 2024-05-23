import 'dart:convert';

import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/wind_direction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

import '../enums/sorting_values.dart';
import '../enums/water_quality.dart';
import '../providers/beaches_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class Beach {
  int id;
  String name;
  String? description;
  String? comments;
  List<BeachSpecifications> beachSpecifications;
  LatLng position;
  String municipality;
  bool isFavourite = false;

  Beach({
    required this.id,
    required this.name,
    required this.description,
    required this.comments,
    required this.beachSpecifications,
    required this.position,
    required this.municipality,
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
      municipality: map["municipality"].toString(),
    );
  }

  BeachSpecifications get getSpecsOfToday =>
      beachSpecifications.firstWhere((element) => element.dataDate.isToday);

  Widget createFavoriteIcon(BuildContext context) => IconButton(
        onPressed: () {
          context.read<BeachesProvider>().changeValueFavoriteBeach = this;
        },
        icon: Icon(
          isFavourite ? Icons.star : Icons.star_outline,
          color: Colors.yellow[600],
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

extension ListOfBeachExtension on List<Beach> {
  List<String> get getBeachesMunicipalityStrings =>
      map((Beach beach) => beach.municipality).toSet().toList();

  List<Beach> sortBeach(SortingOption option, LatLng? userPosition) {
    List<Beach> beachesToReturn = this;
    switch (option.value) {
      case SortingValues.name:
        beachesToReturn = this..sort((a, b) => a.name.compareTo(b.name));
      case SortingValues.distance:
        if (userPosition == null) return this;
        beachesToReturn = this
          ..sort((a, b) => a
              .distanceInKm(userPosition)!
              .compareTo(b.distanceInKm(userPosition)!));
      case SortingValues.waterQuality:
        List<Beach> goodQual =
            getBeachesFromQuality(WaterQualityTypes.goodQuality);
        List<Beach> badQual =
            getBeachesFromQuality(WaterQualityTypes.badQuality);
        List<Beach> noWarn = getBeachesFromQuality(WaterQualityTypes.noWarning);
        List<Beach> closed = getBeachesFromQuality(WaterQualityTypes.closed);
        beachesToReturn = [...goodQual, ...badQual, ...noWarn, ...closed];
      case SortingValues.municipalityName:
        beachesToReturn = this
          ..sort((a, b) => a.municipality.compareTo(b.municipality));
    }
    if (option.isAscending == false) {
      beachesToReturn = beachesToReturn.reversed.toList();
    }
    return beachesToReturn;
  }

  List<Beach> getBeachesFromQuality(WaterQualityTypes quality) {
    return where((beach) => beach.getSpecsOfToday.waterQualityType == quality)
        .toList();
  }

  List<Beach> filterByMunicipality(String municipality) {
    List<Beach> beachesToReturn =  where((beach) => beach.municipality.toLowerCase() == municipality.toLowerCase()).toList();
    print("those to filter ${beachesToReturn.map((e) => e.municipality)}");
    return beachesToReturn;
  }

  List<Beach> filterBySearch(String searchValue) {
    return where(
            (item) => item.name.toLowerCase().contains(searchValue.toLowerCase()))
        .toList();
  }
}
