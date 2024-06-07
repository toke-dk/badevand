import 'dart:convert';

import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/meteo/daily_meteo_data.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../env/env.dart';
import '../models/beach.dart';
import '../models/meteo/weather_data.dart';

Future<List<MeteorologicalData>> getWeatherData(LatLng position) async {
  final DateTime firstDate = DateTime.now();
  final DateTime lastDate = DateTime.now().add(8.days);

  print(firstDate.meteoDateFormatHour);

  final double lat = position.latitude;
  final double lon = position.longitude;

  final String link = _createLink(
      startDate: firstDate,
      endDate: lastDate,
      parameters: [
        "weather_symbol_1h:idx",
        "t_2m:C",
        "precip_1h:mm",
        "wind_speed_10m:ms",
        "wind_dir_10m:d",
        "uv:idx",
        "wind_gusts_10m_1h:ms"
      ],
      lat: lat,
      lon: lon);

  final url = Uri.parse(link);

  // final response = await http.get(url);

  final username = Env.meteoUsername;
  final password = Env.meteoPassword;

  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  final headers = {
    'Authorization': 'Basic ${stringToBase64.encode("$username:$password")}'
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)["data"];
    print(data);
    return getMeteorologicalDataList(data);
  } else {
    // Handle error scenario
    throw Exception('Could not find the data from the links');
  }
}

Future<List<DailyForecastMeteoData>> getDailyForecastData(LatLng position) async {
  final DateTime now = DateTime.now();
  final DateTime firstDate = DateTime(now.year, now.month, now.day, 23);
  final DateTime lastDate = firstDate.add(8.days);

  print(firstDate.meteoDateFormatHour);

  final double lat = position.latitude;
  final double lon = position.longitude;

  final String link = _createLink(
      startDate: firstDate,
      endDate: lastDate,
      parameters: [
        "precip_24h:mm",
        "weather_symbol_24h:idx"
      ],
      timeGap: "24H",
      lat: lat,
      lon: lon);

  final url = Uri.parse(link);

  // final response = await http.get(url);

  final username = Env.meteoUsername;
  final password = Env.meteoPassword;

  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  final headers = {
    'Authorization': 'Basic ${stringToBase64.encode("$username:$password")}'
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)["data"];
    print(data);
    return getDailyMeteorologicalDataList(data);
  } else {
    // Handle error scenario
    throw Exception('Could not find the data from the links');
  }
}

Future<Twilight> getTwilightForToday(position) async {
  final lat = position.latitude;
  final lon = position.longitude;

  final sunRiseAndSetLink = _createLink(
      startDate: DateTime.now().onlyYearMonthDay,
      parameters: ["sunrise:sql", "sunset:sql"],
      lat: lat,
      lon: lon);

  final sunUrl = Uri.parse(sunRiseAndSetLink);

  final username = Env.meteoUsername;
  final password = Env.meteoPassword;

  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  final headers = {
    'Authorization': 'Basic ${stringToBase64.encode("$username:$password")}'
  };

  final sunResponse = await http.get(sunUrl, headers: headers);

  if (sunResponse.statusCode == 200) {
    final List<dynamic> data = jsonDecode(sunResponse.body)["data"];
    return Twilight.fromMeteoMap(data);
  } else {
    // Handle error scenario
    throw Exception('Could not find the data from the links');
  }
}

class Twilight {
  DateTime sunRise;
  DateTime sunSet;

  Twilight({required this.sunRise, required this.sunSet});

  factory Twilight.fromMeteoMap(List<dynamic> map) {
    String getDateFromParameter(String parameter) {
      return map
          .firstWhere((e) => e["parameter"] == parameter)["coordinates"]
          .first["dates"]
          .first["value"]
          .toString();
    }

    // TODO I added two hours in both ends because of its inaccuracy
    final DateTime sunRiseDate =
        DateTime.parse(getDateFromParameter("sunrise:sql")).toLocal();

    final DateTime sunSetDate =
        DateTime.parse(getDateFromParameter("sunset:sql")).toLocal();
    print("set $sunSetDate");

    return Twilight(sunRise: sunRiseDate, sunSet: sunSetDate);
  }
}

String _createLink(
    {required DateTime startDate,
    DateTime? endDate,
    required List<String> parameters,
    required lat,
    required lon,
    String timeGap = "60M",
    String format = "json"}) {
  String dateRange = endDate == null
      ? startDate.meteoDateFormat.toString()
      : "${startDate.meteoDateFormatHour}--${endDate.meteoDateFormat}:PT${timeGap}";
  String linkToReturn =
      'https://api.meteomatics.com/$dateRange/${parameters.join(',')}/${lat},${lon}/$format';
  return linkToReturn;
}
