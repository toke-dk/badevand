import 'dart:math';
import 'dart:math' as math;

extension NumerExtension on num {
  String get myDoubleToString => toStringAsFixed(this % 1 == 0 ? 0 : 1);

  String get asCelsiusTemperature => "$myDoubleToString \u2103";

  String get asMeterPerSecond => "$myDoubleToString m/s";

  String get asMillimetersString => "$myDoubleToString mm";

  double get toRadiansFromDegree => this * pi / 180;
}

extension CoordinateTransform on num {
  /// All conversions are from this source:
  /// https://wiki.openstreetmap.org/wiki/Mercator#JavaScript

  static const pi = math.pi;
  static const radToDeg = 180 / pi;
  static const degToRad = pi / 180;
  static const r = 6378137;

  double get y2lat => (2 * math.atan(math.exp(this / r)) - pi / 2) * radToDeg;

  double get x2lon => radToDeg * (this / r);

  double get lat2y => math.log(math.tan(pi / 4 + this * degToRad / 2) * r);

  double get lon2x => this * degToRad * r;
}

