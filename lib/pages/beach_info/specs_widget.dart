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

    final BeachSpecifications specificationForSelectedIndex =
    widget.beach.beachSpecifications[_selectedDateIndex];

    return specifications.isEmpty ? SizedBox.shrink() : Column(
      children: [
        Row(
          children: [
            widget.beach.getSpecsOfToday.weatherType?.icon ?? SizedBox.shrink(),
            Gap(30),
            Expanded(
              child: Text(
                overflow: TextOverflow.visible,
                widget.beach.getSpecsOfToday.weatherType?.displayedText ??
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