import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/env/env.dart';
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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/beach.dart';
import 'package:http/http.dart' as http;

class BeachInfoPage extends StatefulWidget {
  const BeachInfoPage({super.key, required this.selectedBeach});

  final Beach selectedBeach;

  @override
  State<BeachInfoPage> createState() => _BeachInfoPageState();
}

class _BeachInfoPageState extends State<BeachInfoPage> {
  int? maxLines = 3;

  int _selectedDateIndex = 0;

  Beach get _beach => context
      .watch<BeachesProvider>()
      .getBeaches
      .firstWhere((element) => element == widget.selectedBeach);

  List<dynamic> _receivedData = [];

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<BeachSpecifications> specifications = _beach.beachSpecifications;

    final BeachSpecifications specificationForSelectedIndex =
        _beach.beachSpecifications[_selectedDateIndex];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OutlinedButton(onPressed: () async {
              //   final lat = widget.selectedBeach.position.latitude;
              //   final long = widget.selectedBeach.position.longitude;
              //   List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
              //   print(placemarks);
              // }, child: Text("Test")),
              Row(
                children: [
                  _beach.getSpecsOfToday.waterQualityType.flag,
                  Gap(8),
                  Expanded(
                    child: Text(
                      _beach.name,
                      softWrap: false,
                      style: textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.pin_drop_outlined),
                    onPressed: () {
                      final provider = context.read<HomeMenuIndexProvider>();
                      provider.setMapPageStartLocation(
                          widget.selectedBeach.position);
                      provider.changeSelectedIndex(1);
                      Navigator.of(context).pop();
                    },
                  ),
                  Gap(6),
                  _beach.createFavoriteIcon(context),
                ],
              ),
              _beach.description == "" || _beach.description == null
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          maxLines = maxLines != null ? null : 3;
                        });
                      },
                      child: Text(
                        _beach.description!,
                        style: textTheme.bodySmall!
                            .copyWith(color: Colors.grey[700]),
                        maxLines: maxLines,
                        overflow:
                            maxLines == null ? null : TextOverflow.ellipsis,
                      )),
              _beach.comments == "" || _beach.comments == null
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
                          _beach.comments!,
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
                      title: Text(_beach.municipality),
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
                  _beach.getSpecsOfToday.weatherType?.icon ?? SizedBox.shrink(),
                  Gap(30),
                  Expanded(
                    child: Text(
                      overflow: TextOverflow.visible,
                      _beach.getSpecsOfToday.weatherType?.displayedText ??
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
                    print(temperatures);
                  },
                  child: Text(
                      "Manipulate data ${_receivedData.isEmpty ? '(tom)' : ''}"))
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<dynamic>> getWeatherData() async {
  final url = Uri.parse(
      'https://api.meteomatics.com/2024-05-30T00:00:00Z--2024-06-07T00:00:00Z:PT30M/weather_symbol_1h:idx,t_2m:C,precip_1h:mm,wind_speed_10m:ms/55.867298,11.460067/json');

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
