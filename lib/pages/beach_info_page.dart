import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';

class BeachInfoPage extends StatelessWidget {
  const BeachInfoPage({super.key, required this.selectedBeach});

  final Beach selectedBeach;

  @override
  Widget build(BuildContext context) {
    final Position? userPosition =
        context.watch<UserPositionProvider>().getPosition;

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: Text(selectedBeach.name),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sidst ${selectedBeach.getSpecsOfToday.dataDate}"),
              Text(
                  "Afstand: ${userPosition == null ? '??' : (Geolocator.distanceBetween(userPosition.latitude, userPosition.longitude, selectedBeach.position.latitude, selectedBeach.position.longitude) / 1000).toInt()}km")
            ],
          ),
          Container(
            color: Colors.grey,
            child: Column(
              children: [
                Text(selectedBeach.getSpecsOfToday.dataDate.toString()),
                selectedBeach.getSpecsOfToday.waterQualityType.flag,
                Text("${selectedBeach.getSpecsOfToday.airTemperature}\u2103")
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Kommune"), Text("????")],
          )
        ],
      ),
    );
  }
}
