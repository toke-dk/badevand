import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/meteorological_data_extension.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/meteo/day_grouped_data.dart';
import 'package:badevand/pages/beach_info/weather_info_exapnsions.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../apis/meteomatics_api.dart';
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
  List<MeteorologicalData>? _receivedData;

  Twilight? _twilight;

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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMeteorologicalData();
    });
    super.initState();
  }

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
            Gap(10),
            Column(
              children: [
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
                Text(_receivedData!.first.weatherDescription, style: _textTheme.titleMedium,)
              ],
            ),
            Gap(25),
            ForecastScroll(
              dataList: _receivedData!.take(8).toList(),
            ),
            Gap(35),
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
}
