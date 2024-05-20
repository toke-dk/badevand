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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedBeach.name,
              style: textTheme.titleMedium,
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
                      overflow: maxLines == null ? null : TextOverflow.ellipsis,
                    )),
            const Gap(30),
            Center(
              child: Text(
                widget.selectedBeach.getSpecsOfToday.weatherType
                        ?.displayedText ??
                    "Ukendt vejr",
                style: textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(10),
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
                      .map((e) => MapEntry(
                          e.key, Text(e.value.dataDate.dateAsRelativeString)))),
                  onValueChanged: (newVal) {
                    setState(() {
                      _selectedDateIndex = newVal;
                    });
                  }),
            ),
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text(widget
                  .selectedBeach
                  .beachSpecifications[_selectedDateIndex].dataDate.myDateFormat),
              subtitle: Text("Dato"),
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
              leading: Icon(Icons.air),
              title: Text(widget
                  .selectedBeach
                  .beachSpecifications[_selectedDateIndex]
                  .windSpeed?.asMeterPerSecond ?? "ingen informationer"),
              subtitle: Text("Vindhastighed"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sidst ${widget.selectedBeach.getSpecsOfToday.dataDate}"),
                Text(
                    "Afstand: ${userPosition == null ? '??' : (Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, widget.selectedBeach.position.latitude, widget.selectedBeach.position.longitude) / 1000).toInt()}km")
              ],
            ),
            Container(
              color: Colors.grey,
              child: Column(
                children: [
                  Text(
                      widget.selectedBeach.getSpecsOfToday.dataDate.toString()),
                  widget.selectedBeach.getSpecsOfToday.waterQualityType.flag,
                  Text(
                      "${widget.selectedBeach.getSpecsOfToday.airTemperature}\u2103")
                ],
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Kommune"), Text("????")],
            )
          ],
        ),
      ),
    );
  }
}
