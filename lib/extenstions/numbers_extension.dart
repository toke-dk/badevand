extension NumerExtension on num {
  String get myDoubleToString => toStringAsFixed(this % 1 == 0 ? 0 : 1);

  String get asCelsiusTemperature => "$myDoubleToString \u2103";

  String get asMeterPerSecond => "$myDoubleToString m/s";
}