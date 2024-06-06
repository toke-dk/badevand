import 'dart:convert';

import 'package:badevand/env/env.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/meteorological_data_extension.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/meteo/day_grouped_data.dart';
import 'package:badevand/pages/beach_info/weather_info_exapnsions.dart';
import 'package:badevand/models/wind_direction.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../models/beach.dart';
import '../../models/meteo/weather_data.dart';
import '../../providers/beaches_provider.dart';
import 'forecast_scroll.dart';

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

  late List<DayGroupedMeteorologicalData> _groupedDataWithoutToday =
      _receivedData!.groupData
        ..removeWhere((d) => d.day.isSameDate(DateTime.now()));

  late TextTheme _textTheme = Theme.of(context).textTheme;

  Beach get _beach => context
      .watch<BeachesProvider>()
      .getBeaches
      .firstWhere((element) => element == widget.beach);

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    if (_isAppLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      if (_receivedData == null) {
        return Text("Intet modtaget data");
      } else {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_receivedData!.first.weatherDescription),
                  ),
                ),
                userPosition == null
                    ? SizedBox.shrink()
                    : Expanded(
                        child: ListTile(
                          title: Text(
                              "${userPosition == null ? '???' : (Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, _beach.position.latitude, _beach.position.longitude) / 1000).toInt()}km"),
                          subtitle: Text("Afstand"),
                        ),
                      ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _receivedData!.first.weatherSymbolImage(scale: 0.7),
                Text(
                  _receivedData!.first.temperature.asDegrees,
                  style: _textTheme.displayMedium,
                )
              ],
            ),
            Gap(10),
            ForecastScroll(
              dataList: _receivedData!.take(8).toList(),
            ),
            Gap(15),
            WeatherInfoExpansions(groupedData: _groupedDataWithoutToday),
            Gap(30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(WeatherIcons.sunrise),
                        Gap(10),
                        Text(
                          _twilight?.sunRise.myTimeFormat ?? "",
                        ),
                      ],
                    ),
                    Text("Solopgang", style: _textTheme.labelSmall)
                  ],
                ),
                Gap(25),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(WeatherIcons.sunset),
                        Gap(10),
                        Text(_twilight?.sunSet.myTimeFormat ?? ""),
                      ],
                    ),
                    Text("Solnedgang", style: _textTheme.labelSmall)
                  ],
                ),
              ],
            ),
            Gap(30)
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
        DateTime.parse(getDateFromParameter("sunrise:sql")).toLocal();

    final DateTime sunSetDate =
        DateTime.parse(getDateFromParameter("sunset:sql")).toLocal();
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
