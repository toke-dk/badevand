import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/meteorological_data_extension.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/meteo/daily_meteo_data.dart';
import 'package:badevand/models/meteo/day_grouped_data.dart';
import 'package:badevand/pages/beach_info/weather_info_exapnsions.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart';

import '../../apis/meteomatics_api.dart';
import '../../models/ad_state.dart';
import '../../models/beach.dart';
import '../../models/meteo/weather_data.dart';
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
  List<DayGroupedMeteorologicalData>? _receivedData;

  Twilight? _twilight;

  bool get _isAppLoading => context.watch<LoadingProvider>().getIsAppLoading;

  late List<DayGroupedMeteorologicalData> _groupedDataWithoutToday =
      _receivedData!.where((d) => d.day.isAfter(DateTime.now())).toList();

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

  late MeteorologicalData _currentMomentData =
      _receivedData!.first.dataList.first;

  BannerAd? banner;

  @override
  void didChangeDependencies() {
    final adState = Provider.of<AdState>(context);

    adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            listener: adState.bannerAdListener,
            request: AdRequest())
          ..load();
      });
    });
    super.didChangeDependencies();
  }

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
                    _currentMomentData.getWeatherType
                        .weatherSymbolImage(scale: 0.7),
                    Text(
                      _currentMomentData.temperature.asDegrees,
                      style: _textTheme.displayMedium,
                    )
                  ],
                ),
                Text(
                  _currentMomentData.getWeatherType.weatherDescription,
                  style: _textTheme.titleMedium,
                )
              ],
            ),
            Gap(25),
            ForecastScroll(
              dataList: _receivedData!.first.dataList,
            ),
            if (banner == null)
              SizedBox(
                height: 60,
              )
            else
              Container(
                height: 60,
                child: Center(
                  child: StatefulBuilder(
                      builder: (context, setState) {
                        return AdWidget(
                          ad: banner!,
                        );
                      }
                  ),
                ),
              ),
            Gap(25),
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

    final List<MeteorologicalData> meteoData =
        await getWeatherData(widget.beach.position);

    final List<DailyForecastMeteoData> forecastMeteoData =
        await getDailyForecastData(widget.beach.position);

    print(forecastMeteoData.map((e) => e.precipitation24h));

    _receivedData = groupMeteoData(meteoData, forecastMeteoData);

    await getTwilightForToday(widget.beach.position).then((twilight) {
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
