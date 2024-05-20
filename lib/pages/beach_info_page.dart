import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/beach.dart';

class BeachInfoPage extends StatefulWidget {
  const BeachInfoPage({super.key, required this.selectedBeach});

  final Beach selectedBeach;

  @override
  State<BeachInfoPage> createState() => _BeachInfoPageState();
}

class _BeachInfoPageState extends State<BeachInfoPage> {
  int? maxLines = 3;

  int _selectedDateIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<BeachSpecifications> specifications =
        widget.selectedBeach.beachSpecifications;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widget.selectedBeach.getSpecsOfToday.waterQualityType.flag,
                  Gap(8),
                  Text(
                    widget.selectedBeach.name,
                    style: textTheme.titleMedium,
                  ),
                  Spacer(),
                  Icon(
                    Icons.star_border,
                    color: Colors.yellow[600],
                    size: 30,
                  ),
                ],
              ),
              widget.selectedBeach.description == null
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          maxLines = maxLines != null ? null : 3;
                        });
                      },
                      child: Text(
                        widget.selectedBeach.description!,
                        style: textTheme.bodySmall!
                            .copyWith(color: Colors.grey[700]),
                        maxLines: maxLines,
                        overflow:
                            maxLines == null ? null : TextOverflow.ellipsis,
                      )),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(widget.selectedBeach.municipality),
                      subtitle: Text("Kommune"),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                          "${userPosition == null ? '???' : (Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, widget.selectedBeach.position.latitude, widget.selectedBeach.position.longitude) / 1000).toInt()}km"),
                      subtitle: Text("Afstand"),
                    ),
                  ),
                ],
              ),
              Gap(20),
              Row(
                children: [
                  widget.selectedBeach.getSpecsOfToday.weatherType?.icon ??
                      SizedBox.shrink(),
                  Gap(30),
                  Expanded(
                    child: Text(
                      overflow: TextOverflow.visible,
                      widget.selectedBeach.getSpecsOfToday.weatherType
                              ?.displayedText ??
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
                title: Text(widget
                    .selectedBeach
                    .beachSpecifications[_selectedDateIndex]
                    .dataDate
                    .myDateFormat),
                subtitle: Text("Dato"),
              ),
              Divider(),
              ListTile(
                leading: widget
                        .selectedBeach
                        .beachSpecifications[_selectedDateIndex]
                        .weatherType
                        ?.icon ??
                    Icon(Icons.question_mark),
                title: Text(widget
                        .selectedBeach
                        .beachSpecifications[_selectedDateIndex]
                        .weatherType
                        ?.displayedText ??
                    "Ukendt vejrtype"),
              ),
              ListTile(
                leading: Icon(Icons.water_drop_outlined),
                title: Text(widget
                    .selectedBeach
                    .beachSpecifications[_selectedDateIndex]
                    .waterTemperature
                    .asCelsiusTemperature),
                subtitle: Text("Vandtemperatur"),
              ),
              ListTile(
                leading: Icon(Icons.thermostat),
                title: Text(widget
                    .selectedBeach
                    .beachSpecifications[_selectedDateIndex]
                    .airTemperature
                    .asCelsiusTemperature),
                subtitle: Text("Lufttemperatur"),
              ),
              ListTile(
                leading: widget
                        .selectedBeach
                        .beachSpecifications[_selectedDateIndex]
                        .windDirection
                        ?.getChildWidget ??
                    const Icon(Icons.question_mark),
                title: Text(widget
                        .selectedBeach
                        .beachSpecifications[_selectedDateIndex]
                        .windSpeed
                        ?.asMeterPerSecond ??
                    "ingen informationer"),
                subtitle: Text("Vind"),
              ),
              ListTile(
                leading: Icon(WeatherIcons.rain),
                title: Text(widget
                        .selectedBeach
                        .beachSpecifications[_selectedDateIndex]
                        .precipitation
                        ?.asMillimetersString ??
                    "ingen informationer"),
                subtitle: Text("Nedbør"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
