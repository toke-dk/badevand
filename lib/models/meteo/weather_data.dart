import 'package:badevand/models/meteo/date_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeteoWeatherData {
  LatLng location;
  List<DateInfo> dateInfo;

  MeteoWeatherData({required this.location, required this.dateInfo});

  factory MeteoWeatherData.fromMap(Map<String, dynamic> map) {
    final List<dynamic> coordinateData = map["coordinates"];
    final double lat = coordinateData.first["lat"] as double;
    final double lon = coordinateData.first["lon"] as double;
    return MeteoWeatherData(
        location: LatLng(lat, lon),
        dateInfo: (coordinateData.first["dates"] as List<dynamic>)
            .map((e) => DateInfo.fromMap(e))
            .toList());
  }
}
