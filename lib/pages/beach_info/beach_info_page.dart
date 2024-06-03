import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/env/env.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/pages/beach_info/specs_widget.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/beach.dart';
import 'package:http/http.dart' as http;

class BeachInfoPage extends StatefulWidget {
  const BeachInfoPage({super.key, required this.selectedBeach});

  final Beach selectedBeach;

  @override
  State<BeachInfoPage> createState() => _BeachInfoPageState();
}

class _BeachInfoPageState extends State<BeachInfoPage> {
  int? maxLines = 3;


  Beach get _beach => context
      .watch<BeachesProvider>()
      .getBeaches
      .firstWhere((element) => element == widget.selectedBeach);

  late BeachSpecifications? specsToday = _beach.getSpecsOfToday;

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    final TextTheme textTheme = Theme.of(context).textTheme;

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
                  specsToday?.waterQualityType.flag ?? SizedBox.shrink(),
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
                                "${userPosition == null ? '???' : (Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, _beach.position.latitude, _beach.position.longitude) / 1000).toInt()}km"),
                            subtitle: Text("Afstand"),
                          ),
                        ),
                ],
              ),
              Gap(20),
              SpecsWidget(beach: widget.selectedBeach),
            ],
          ),
        ),
      ),
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
