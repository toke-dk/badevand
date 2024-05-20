import '../models/beach.dart';

extension NumerExtension on num {
  String get myDoubleToString => toStringAsFixed(this % 1 == 0 ? 0 : 1);

  String get asCelsiusTemperature => "$myDoubleToString \u2103";

  String get asMeterPerSecond => "$myDoubleToString m/s";

  WindDirection get getClosestWindDirection {
    // Normalize the angle to 0-360 range
    final angle = this % 360;

    // Define angle ranges for each direction (considering a 22.5 degree tolerance)
    final directionRanges = {
      WindDirection.north: const Range(0, 22.5),
      WindDirection.northEast: const Range(22.5, 67.5),
      WindDirection.east: const Range(67.5, 112.5),
      WindDirection.southEast: const Range(112.5, 157.5),
      WindDirection.south: const Range(157.5, 202.5),
      WindDirection.southWest: const Range(202.5, 247.5),
      WindDirection.west: const Range(247.5, 292.5),
      WindDirection.northWest: const Range(292.5, 337.5),
    };

    // Find the direction whose range encompasses the angle
    return directionRanges.entries.firstWhere((entry) => entry.value.contains(angle.toDouble())).key;
  }
}