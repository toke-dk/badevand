import 'dart:convert';

import 'package:badevand/env/env.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/wind_direction.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../models/beach.dart';
import '../../models/meteo/weather_data.dart';

class SpecsWidget extends StatefulWidget {
  SpecsWidget({
    super.key,
    required this.beach,
  });

  final Beach beach;

  @override
  State<SpecsWidget> createState() => _SpecsWidgetState();
}

class _SpecsWidgetState extends State<SpecsWidget> {
  int? maxLines = 3;

  List<MeteorologicalData>? _receivedData;

  Twilight? _twilight;

  Future<void> initMeteorologicalData() async {
    context.read<LoadingProvider>().toggleAppLoadingState(true);
    await getWeatherData(widget.beach).then((result) {
      setState(() {
        _receivedData = result;
      });
    });

    await getTwilightForToday(widget.beach).then((twilight) {
      setState(() {
        _twilight = twilight;
      });
      context.read<LoadingProvider>().toggleAppLoadingState(false);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMeteorologicalData();
    });
    super.initState();
  }

  bool get _isAppLoading => context.watch<LoadingProvider>().getIsAppLoading;

  MeteorologicalData get _currentMomentData => _receivedData!.first;

  @override
  Widget build(BuildContext context) {
    if (_isAppLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (_receivedData == null) {
        return Text("Intet modtaget data");
      } else {
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(8, (index) {
                  MeteorologicalData indexData = _receivedData![index];
                  return IntrinsicHeight(
                    child: Row(
                      children: [
                        VerticalDivider(),
                        Column(
                          children: [
                            Text(indexData.date.myTimeFormat),
                            indexData.weatherSymbolImage,
                            Text(indexData.temperature.asCelsiusTemperature)
                          ],
                        ),
                        index != 7 ? SizedBox.shrink() : VerticalDivider(),
                      ],
                    ),
                  );
                }),
              ),
            ),
            _receivedData == null
                ? SizedBox.shrink()
                : ListTile(
                    leading: Icon(Icons.thermostat),
                    title: Text(
                        _currentMomentData.temperature.asCelsiusTemperature),
                    subtitle: Text("Lufttemperatur"),
                  ),
            _receivedData == null
                ? SizedBox.shrink()
                : ListTile(
                    leading:
                        WindDirection(angle: _currentMomentData.windDirection)
                            .getChildWidget,
                    title: Text(
                        "${_currentMomentData.windSpeed}/(${_currentMomentData.windGust}) m/s"),
                    subtitle: Text("Vind/(Stød)"),
                  ),
            _receivedData == null
                ? SizedBox.shrink()
                : ListTile(
                    leading: Icon(WeatherIcons.rain),
                    title: Text(
                        "${_currentMomentData.precipitation == 0 ? '---' : '${_currentMomentData.precipitation} mm'}"),
                    subtitle: Text("Nedbør"),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(WeatherIcons.sunrise),
                Gap(10),
                Text(_twilight?.sunRise.myTimeFormat ?? ""),
                Gap(20),
                Icon(WeatherIcons.sunset),
                Gap(10),
                Text(_twilight?.sunSet.myTimeFormat ?? ""),
              ],
            )
          ],
        );
      }
    }
  }
}

Future<List<MeteorologicalData>> getWeatherData(Beach beach) async {
  final DateTime firstDate = DateTime.now();
  final DateTime lastDate = DateTime.now().add(8.days);

  print(firstDate.meteoDateFormatHour);

  final double lat = beach.position.latitude;
  final double lon = beach.position.longitude;

  final String link = createLink(
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

Future<Twilight> getTwilightForToday(Beach beach) async {
  final lat = beach.position.latitude;
  final lon = beach.position.longitude;

  final sunRiseAndSetLink = createLink(
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
        DateTime.parse(getDateFromParameter("sunrise:sql")).add(2.hours);

    final DateTime sunSetDate =
        DateTime.parse(getDateFromParameter("sunset:sql")).add(2.hours);
    print("set $sunSetDate");

    return Twilight(sunRise: sunRiseDate, sunSet: sunSetDate);
  }
}

String createLink(
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
