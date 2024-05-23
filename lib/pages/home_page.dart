import 'dart:convert';
import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/widgets/filter_bottom_sheet.dart';
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

  List<Beach> get _filteredBeaches => context.watch<BeachesProvider>().getFilteredBeaches;

  @override
  Widget build(BuildContext context) {

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
                hintText: 'Søg',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, right: 20, left: 8),
                    child: FittedBox(
                        child: badges.Badge(
                      badgeContent: const Text(
                        "0",
                        style: TextStyle(color: Colors.white),
                      ),
                      position:
                          badges.BadgePosition.topStart(top: -12, start: 12),
                      child: const Icon(Icons.tune),
                    ))),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onChanged: (value) {
              },
            ),
          ),
          const Gap(10),
          beaches.isEmpty ? const SizedBox.shrink() : const FilterBottomSheet(),
          const Gap(10),
          Column(
            children: List.generate(_filteredBeaches.length, (index) {
              final Beach indexBeach = _filteredBeaches[index];
              return ListTile(
                trailing: indexBeach.createFavoriteIcon(context),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        BeachInfoPage(selectedBeach: indexBeach))),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(indexBeach.name)),
                    Gap(6),
                    Text(indexBeach.municipality, style: TextStyle(fontSize: 11, color: Colors.grey[700]),),
                  ],
                ),
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
