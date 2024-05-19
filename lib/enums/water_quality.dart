import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum WaterQualityTypes { badQuality, goodQuality, noWarning, closed }

extension WaterQualityTypesExtension on WaterQualityTypes {
  String get description {
    switch (this) {
      case WaterQualityTypes.badQuality:
        return "Dårlig badevandskvalitet";
      case WaterQualityTypes.goodQuality:
        return "God badevandskvalitet";
      case WaterQualityTypes.noWarning:
        return "Ingen automatisk varsling";
      case WaterQualityTypes.closed:
        return "Badested lukket for sæsonen";
    }
  }

  Widget get flag {
    switch (this) {
      case WaterQualityTypes.badQuality:
        return const Icon(
          Icons.flag,
          color: Colors.red,
        );
      case WaterQualityTypes.goodQuality:
        return const Icon(
          Icons.flag,
          color: Colors.green,
        );
      case WaterQualityTypes.noWarning:
        return const Icon(
          Icons.flag,
          color: Colors.amber,
        );
      case WaterQualityTypes.closed:
        return const Icon(
          Icons.flag,
          color: Colors.grey,
        );
    }
  }
}

WaterQualityTypes? convertIntToQualityType(int value) {
  switch (value) {
    case 1:
      return WaterQualityTypes.badQuality;
    case 2:
      return WaterQualityTypes.goodQuality;
    case 3:
      return WaterQualityTypes.noWarning;
    case 4:
      return WaterQualityTypes.closed;
    default:
      return null;
  }
}
