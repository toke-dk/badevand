import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/models/meteo/weather_data.dart';
import 'package:flutter/material.dart';

class ForecastScroll extends StatelessWidget {
  const ForecastScroll({super.key, required this.dataList});

  final List<MeteorologicalData> dataList;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(dataList.length, (index) {
          MeteorologicalData indexData = dataList[index];
          return IntrinsicHeight(
            child: Row(
              children: [
                index == 0 ? SizedBox.shrink() : VerticalDivider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Text(indexData.date.myTimeFormat),
                      indexData.weatherSymbolImage,
                      Text(indexData.temperature.asCelsiusTemperature),
                      Text(indexData.precipitation == 0
                          ? ""
                          : indexData.precipitation.asMillimetersString),
                      indexData.windDirection.getWindDirectionSymbol,
                      Text(indexData.windSpeed.asMeterPerSecond),
                      Text(
                        "Vindstød ${indexData.windGust.asMeterPerSecond}",
                      ),
                      Text("UV ${indexData.uvIndex.myDoubleToString}")
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
