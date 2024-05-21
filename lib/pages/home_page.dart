import 'dart:convert';
import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';
import '../providers/beaches_provider.dart';
import '../providers/google_markers_provider.dart';
import 'beach_info_page.dart';
import 'package:badges/badges.dart' as badges;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Beach> get beaches => context.watch<BeachesProvider>().getBeaches;

  void _filterBeaches(String value) {
    setState(() {
      _filteredBeaches = context
          .read<BeachesProvider>()
          .getBeaches
          .where(
              (item) => item.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  List<Beach> _filteredBeaches = [];

  @override
  Widget build(BuildContext context) {
    _filteredBeaches = _filteredBeaches.isNotEmpty
        ? _filteredBeaches
        : context.read<BeachesProvider>().getBeaches;

    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Den bedste badevandsapp"),
          OutlinedButton(
              onPressed: () async {
                List<dynamic> result = await getBeachData();

                context.read<BeachesProvider>().setBeaches =
                    result.map((e) => Beach.fromMap(e)).toList();
                await context
                    .read<GoogleMarkersProvider>()
                    .initMarkers(context);
              },
              child: Text(
                  "Get data (${beaches.isNotEmpty ? 'hasData' : "hasNotData"})")),
          OutlinedButton(
              onPressed: () async {
                print(beaches);
              },
              child: const Text("Convert to dart class")),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, right: 20, left: 8),
                    child: FittedBox(
                        child: badges.Badge(
                      child: const Icon(Icons.tune),
                      badgeContent: Text(
                        "0",
                        style: TextStyle(color: Colors.white),
                      ),
                      position:
                          badges.BadgePosition.topStart(top: -12, start: 12),
                    ))),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (value) {
                _filterBeaches(value);
              },
            ),
          ),
          Gap(10),
          Column(
            children: List.generate(_filteredBeaches.length, (index) {
              final Beach indexBeach = _filteredBeaches[index];
              return ListTile(
                trailing: indexBeach.createFavoriteIcon(context),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        BeachInfoPage(selectedBeach: indexBeach))),
                title: Text(indexBeach.name),
                leading: indexBeach.getSpecsOfToday.waterQualityType.flag,
                subtitle: Row(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      color: Colors.blue[800],
                    ),
                    const Gap(4),
                    Text(indexBeach
                        .getSpecsOfToday.waterTemperature.asCelsiusTemperature),
                    const Gap(10),
                    indexBeach.getSpecsOfToday.weatherType?.icon ??
                        const SizedBox.shrink(),
                    const Gap(8),
                    Text(indexBeach
                        .getSpecsOfToday.airTemperature.asCelsiusTemperature)
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

Future<List<dynamic>> getBeachData() async {
  final url = Uri.parse('http://api.vandudsigten.dk/beaches');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    print(data[1]["name"]);
    return data;
  } else {
    // Handle error scenario
    throw Exception('Could not find the data from the vandusigt link:(');
  }
}
