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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMeteorologicalData();
    });
    super.initState();
  }

  late Position? userPosition =
      context.watch<UserPositionProvider>().getPosition;

  @override
  Widget build(BuildContext context) {
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
                              "${userPosition == null ? '???' : (Geolocator.distanceBetween(userPosition!.latitude, userPosition!.longitude, widget.beach.position.latitude, widget.beach.position.longitude) / 1000).toInt()}km"),
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
                Text(
                  _receivedData!.first.weatherDescription,
                  style: _textTheme.titleMedium,
                )
              ],
            ),
            Gap(25),
            ForecastScroll(
              dataList: _receivedData!.take(8).toList(),
            ),
            Gap(35),
            WeatherInfoExpansions(groupedData: _groupedDataWithoutToday),
            Gap(30),
            SunRiseSunsetWidget(twilight: _twilight),
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

class SunRiseSunsetWidget extends StatelessWidget {
  const SunRiseSunsetWidget({super.key, required this.twilight});

  final Twilight? twilight;

  @override
  Widget build(BuildContext context) {
    final TextTheme _textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        makeIconWithText(
            twilight: twilight, isSunrise: true, textTheme: _textTheme),
        Gap(25),
        makeIconWithText(
            twilight: twilight, isSunrise: false, textTheme: _textTheme),
      ],
    );
  }

  Widget makeIconWithText(
      {required Twilight? twilight,
      required bool isSunrise,
      required TextTheme textTheme}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(isSunrise ? WeatherIcons.sunrise : WeatherIcons.sunset),
            Gap(10),
            Text(isSunrise
                ? twilight?.sunRise.myTimeFormat ?? ""
                : twilight?.sunSet.myTimeFormat ?? "?"),
          ],
        ),
        Text(isSunrise ? "Solopgang" : "Solnedgang",
            style: textTheme.labelSmall)
      ],
    );
  }
}
