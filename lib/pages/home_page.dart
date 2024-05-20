import 'dart:convert';
import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';
import '../providers/beaches_provider.dart';
import 'beach_info_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    List<Beach> beaches = context.watch<BeachesProvider>().getBeaches;

    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Den bedste badevandsapp"),
          OutlinedButton(
              onPressed: () async {
                List<dynamic> result = await getBeachData();

                context.read<BeachesProvider>().setBeaches =
                    result.map((e) => Beach.fromMap(e)).toList();
              },
              child: Text(
                  "Get data (${beaches.isNotEmpty ? 'hasData' : "hasNotData"})")),
          OutlinedButton(
              onPressed: () async {
                print(beaches);
              },
              child: const Text("Convert to dart class")),
          Column(
            children: List.generate(beaches.length, (index) {
              final Beach indexBeach = beaches[index];
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
