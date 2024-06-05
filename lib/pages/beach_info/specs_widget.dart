import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/env/env.dart';
import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/wind_direction.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
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

  Future<void> initMeteorologicalData() async {
    context.read<LoadingProvider>().toggleAppLoadingState(true);
    await getWeatherData(widget.beach).then((result) {
      setState(() {
        _receivedData = result;
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

  @override
  Widget build(BuildContext context) {
    if (_isAppLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          _receivedData == null
              ? SizedBox.shrink()
              : ListTile(
                  leading: Icon(Icons.thermostat),
                  title: Text(_receivedData!
                      .first.temperature.asCelsiusTemperature),
                  subtitle: Text("Lufttemperatur"),
                ),
          _receivedData == null
              ? SizedBox.shrink()
              : ListTile(
                  leading: WindDirection(
                          angle: _receivedData!.first.windDirection)
                      .getChildWidget,
                  title: Text(
                      _receivedData!.first.windSpeed.asMeterPerSecond),
                  subtitle: Text("Vind"),
                ),
        ],
      );
    }
  }
}

Future<List<MeteorologicalData>> getWeatherData(Beach beach) async {
  final DateTime firstDate = DateTime.now();
  final DateTime lastDate = DateTime.now().add(8.days);

  print(firstDate.meteoDateFormatHour);

  final url = Uri.parse(
      'https://api.meteomatics.com/${firstDate.meteoDateFormatHour}--${lastDate.meteoDateFormat}:PT30M/weather_symbol_1h:idx,t_2m:C,precip_1h:mm,wind_speed_10m:ms,wind_dir_10m:d,uv:idx,wind_gusts_10m_1h:ms/${beach.position.latitude},${beach.position.longitude}/json');

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
    throw Exception('Could not find the data from the link');
  }
}
