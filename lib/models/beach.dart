
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/meteo/day_grouped_data.dart';
import 'package:badevand/models/wind_direction.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../enums/water_quality.dart';
import '../providers/beaches_provider.dart';
import 'dhi/dhi_specifications.dart';

class Beach {
  String id;
  String name;
  String? description;
  String? comments;
  List<DhiBeachSpecifications> dhiBeachSpecifications;
  List<DayGroupedMeteorologicalData> meteoData;
  LatLng position;
  String municipality;
  bool isFavourite;

  Beach({
    required this.id,
    required this.name,
    this.description,
    this.comments,
    this.dhiBeachSpecifications = const [],
    this.meteoData = const [],
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
      dhiBeachSpecifications: (map["data"] as List<dynamic>)
          .map((dataMap) => DhiBeachSpecifications.fromMap(dataMap))
          .toList(),
      position: LatLng(double.parse(map["latitude"].toString()),
          double.parse(map["longitude"].toString())),
      municipality: map["municipality"].toString(),
      isFavourite: isBeachFavourite,
    );
  }

  DhiBeachSpecifications? get getSpecsOfToday {
    if (dhiBeachSpecifications.indexWhere((specs) => specs.dataDate.isToday) == -1)
      return null;

    return dhiBeachSpecifications
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

