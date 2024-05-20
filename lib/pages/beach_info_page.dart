import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:badevand/enums/weather_types.dart';

import '../models/beach.dart';

class BeachInfoPage extends StatefulWidget {
  const BeachInfoPage({super.key, required this.selectedBeach});

  final Beach selectedBeach;

  @override
  State<BeachInfoPage> createState() => _BeachInfoPageState();
}

class _BeachInfoPageState extends State<BeachInfoPage> {
  int? maxLines = 3;

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<BeachSpecifications> specifications = widget.selectedBeach.beachSpecifications;

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
            Gap(30),
            Center(
              child: Text(
                widget.selectedBeach.getSpecsOfToday.weatherType
                        ?.displayedText ??
                    "Ukendt vejr",
                style: textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            CustomSlidingSegmentedControl(
                customSegmentSettings: CustomSegmentSettings(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.grey[300]),
                thumbDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                children: Map<int, Widget>.fromEntries(specifications.asMap().entries.map((e) => MapEntry(e.key, Text(e.value.dataDate.dateAsRelativeString)))),
                onValueChanged: (newVal) {}),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Kommune"), Text("????")],
            )
          ],
        ),
      ),
    );
  }
}
