import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/env/env.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../models/beach.dart';
import 'package:http/http.dart' as http;

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../models/beach.dart';
import '../../models/meteo/weather_data.dart';
import 'beach_info_page.dart';

class SpecsWidget extends StatefulWidget {
  SpecsWidget({super.key, required this.beach, });

  final Beach beach;

  @override
  State<SpecsWidget> createState() => _SpecsWidgetState();
}

class _SpecsWidgetState extends State<SpecsWidget> {
  int? maxLines = 3;

  int _selectedDateIndex = 0;

  List<dynamic> _receivedData = [];

  @override
  Widget build(BuildContext context) {

    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<BeachSpecifications> specifications = widget.beach.beachSpecifications;

    final BeachSpecifications? specificationForSelectedIndex =
    specifications.isEmpty ? null : widget.beach.beachSpecifications[_selectedDateIndex];
    
    late BeachSpecifications? specsToday = widget.beach.getSpecsOfToday;

    return specificationForSelectedIndex == null ? SizedBox.shrink() : Column(
      children: [
        Row(
          children: [
            specsToday?.weatherType?.icon ?? SizedBox.shrink(),
            Gap(30),
            Expanded(
              child: Text(
                overflow: TextOverflow.visible,
                specsToday?.weatherType?.displayedText ??
                    "Ukendt vejr",
                style: textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const Gap(35),
        Center(
          child: CustomSlidingSegmentedControl(
              innerPadding: const EdgeInsets.all(8),
              customSegmentSettings: CustomSegmentSettings(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withAlpha(100)),
              thumbDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(
                      0.0,
                      2.0,
                    ),
                  ),
                ],
              ),
              children: Map<int, Widget>.fromEntries(specifications
                  .asMap()
                  .entries
                  .map((e) => MapEntry(e.key,
                  Text(e.value.dataDate.dateAsRelativeString)))),
              onValueChanged: (newVal) {
                setState(() {
                  _selectedDateIndex = newVal;
                });
              }),
        ),
        Gap(10),
        ListTile(
          leading: Icon(Icons.date_range),
          title:
          Text(specificationForSelectedIndex.dataDate.myDateFormat),
          subtitle: Text("Dato"),
        ),
        Divider(),
        ListTile(
          leading: specificationForSelectedIndex.waterQualityType.flag,
          title: Text(
              specificationForSelectedIndex.waterQualityType.description),
          subtitle: Text("Vandkvalitet"),
        ),
        ListTile(
          leading: specificationForSelectedIndex.weatherType?.icon ??
              Icon(Icons.question_mark),
          title: Text(
              specificationForSelectedIndex.weatherType?.displayedText ??
                  "Ukendt vejrtype"),
        ),
        ListTile(
          leading: Icon(Icons.water_drop_outlined),
          title: Text(specificationForSelectedIndex
              .waterTemperature.asCelsiusTemperature),
          subtitle: Text("Vandtemperatur"),
        ),
        ListTile(
          leading: Icon(Icons.thermostat),
          title: Text(specificationForSelectedIndex
              .airTemperature.asCelsiusTemperature),
          subtitle: Text("Lufttemperatur"),
        ),
        ListTile(
          leading: specificationForSelectedIndex
              .windDirection?.getChildWidget ??
              const Icon(Icons.question_mark),
          title: Text(
              specificationForSelectedIndex.windSpeed?.asMeterPerSecond ??
                  "ingen informationer"),
          subtitle: Text("Vind"),
        ),
        ListTile(
          leading: Icon(WeatherIcons.rain),
          title: Text(specificationForSelectedIndex
              .precipitation?.asMillimetersString ??
              "ingen informationer"),
          subtitle: Text("Nedbør"),
        ),
        OutlinedButton(
            onPressed: () async {
              _receivedData = await getWeatherData();
              setState(() {});
            },
            child: Text("Get data")),
        OutlinedButton(
            onPressed: () async {
              final temperatures = _receivedData.firstWhere(
                      (e) => e["parameter"] == "t_2m:C")["coordinates"].first["dates"].first["value"];
              print(DateTime.now().meteoDateFormat);
              print(MeteoWeatherData.fromMap(_receivedData, "t_2m:C"));
            },
            child: Text(
                "Manipulate data ${_receivedData.isEmpty ? '(tom)' : ''}"))
      ],
    );
  }
}

Future<List<dynamic>> getWeatherData() async {
  final DateTime firstDate = DateTime.now().subtract(1.days);
  final DateTime lastDate = DateTime.now().add(8.days);

  final url = Uri.parse(
      'https://api.meteomatics.com/${firstDate.meteoDateFormat}--${lastDate.meteoDateFormat}:PT30M/weather_symbol_1h:idx,t_2m:C,precip_1h:mm,wind_speed_10m:ms/55.867298,11.460067/json');

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
    return data;
  } else {
    // Handle error scenario
    throw Exception('Could not find the data from the link');
  }
}