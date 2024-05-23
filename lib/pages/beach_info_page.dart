import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
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

  Beach get beach => context
      .read<BeachesProvider>()
      .getBeaches
      .firstWhere((element) => element == widget.selectedBeach);

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<BeachSpecifications> specifications = beach.beachSpecifications;

    final BeachSpecifications specificationForSelectedIndex =
        beach.beachSpecifications[_selectedDateIndex];

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
                  beach.getSpecsOfToday.waterQualityType.flag,
                  Gap(8),
                  Text(
                    beach.name,
                    style: textTheme.titleMedium,
                  ),
                  Spacer(),
                  IconButton(icon: Icon(Icons.pin_drop_outlined), onPressed: () {
                    final provider = context.read<HomeMenuIndexProvider>();
                    provider.setMapPageStartLocation(beach.position);
                    provider.changeSelectedIndex(1);
                    Navigator.of(context).pop();
                  },),
                  Gap(6),
                  beach.createFavoriteIcon(context),
                ],
              ),
              beach.description == "" || beach.description == null
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          maxLines = maxLines != null ? null : 3;
                        });
                      },
                      child: Text(
                        beach.description!,
                        style: textTheme.bodySmall!
                            .copyWith(color: Colors.grey[700]),
                        maxLines: maxLines,
                        overflow:
                            maxLines == null ? null : TextOverflow.ellipsis,
                      )),
              beach.comments == "" || beach.comments == null
                  ? const SizedBox.shrink()
                  : GestureDetector(
                  onTap: () {
                    setState(() {
                      maxLines = maxLines != null ? null : 3;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: Text(
                      beach.comments!,
                      style: textTheme.bodySmall!
                          .copyWith(color: Colors.grey[700]),
                      maxLines: maxLines,
                      overflow:
                      maxLines == null ? null : TextOverflow.ellipsis,
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(beach.municipality),
                      subtitle: Text("Kommune"),
                    ),
                  ),
                  userPosition == null
                      ? SizedBox.shrink()
                      : Expanded(
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
                  beach.getSpecsOfToday.weatherType?.icon ?? SizedBox.shrink(),
                  Gap(30),
                  Expanded(
                    child: Text(
                      overflow: TextOverflow.visible,
                      beach.getSpecsOfToday.weatherType?.displayedText ??
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
                title: Text(specificationForSelectedIndex.waterQualityType.description),
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
            ],
          ),
        ),
      ),
    );
  }
}
