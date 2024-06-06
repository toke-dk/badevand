import 'package:badevand/extenstions/date_extensions.dart';
import 'package:badevand/models/meteo/forecast_scroll.dart';
import 'package:flutter/material.dart';

import 'day_grouped_data.dart';

class WeatherInfoExpansions extends StatefulWidget {
  const WeatherInfoExpansions({super.key, required this.groupedData});

  final List<DayGroupedMeteorologicalData> groupedData;

  @override
  State<WeatherInfoExpansions> createState() => _WeatherInfoExpansionsState();
}

class _WeatherInfoExpansionsState extends State<WeatherInfoExpansions> {
  final List<int> _expandedIndexes = [];

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          if (isExpanded) {
            _expandedIndexes.add(index);
          } else {
            _expandedIndexes.remove(index);
          }
        });
        print(_expandedIndexes);
      },
      expandedHeaderPadding: EdgeInsets.all(20),
      children: List.generate(widget.groupedData.length, (index) {
        final idxData = widget.groupedData[index];
        return ExpansionPanel(

            headerBuilder: (context, isExpanded) {
              return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(idxData.day.myDateFormat),
                  ));
            },
            isExpanded: _expandedIndexes.contains(index),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: ForecastScroll(dataList: idxData.dataList),
            ));
      }),
    );
  }
}
