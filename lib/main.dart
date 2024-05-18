import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {



  int _selectedMenuIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      const Home(),
      const MapPage(),
    ];

    return ChangeNotifierProvider(
      create: (BuildContext context) => BeachesProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Badevand"),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.water), label: "Hjem"),
              BottomNavigationBarItem(icon: Icon(Icons.map), label: "Kort"),
            ],
            currentIndex: _selectedMenuIndex,
            onTap: (int newIndex) => setState(() {
              _selectedMenuIndex = newIndex;
            }),
          ),
          body: SingleChildScrollView(
            child: _pages.elementAt(_selectedMenuIndex)
          ),
        ),
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

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    List<Beach> beaches = context.watch<BeachesProvider>().getBeaches;

    return Column(
      children: [
        const Text("Den bedste badevandsapp"),
        OutlinedButton(
            onPressed: () async {
              List<dynamic> result = await getBeachData();

              context.read<BeachesProvider>().setBeaches(result.map((e) => Beach.fromMap(e)).toList());

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
              title: Text(indexBeach.name),
              leading: indexBeach.getSpecsOfToday.waterQualityType.flag,
              subtitle: Row(
                children: [
                  const Icon(Icons.water_drop_outlined),
                  const Gap(4),
                  Text(
                      "${indexBeach.getSpecsOfToday.waterTemperature} \u2103"),
                  const Gap(10),
                  indexBeach.getSpecsOfToday.weatherType.icon,
                  const Gap(4),
                  Text(
                      "${indexBeach.getSpecsOfToday.airTemperature} \u2103")
                ],
              ),
            );
          }),
        )
      ],
    );
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {

    List<Beach> beaches = context.watch<BeachesProvider>().getBeaches;

    return Column(
      children: [
        Text(beaches.first.name)
      ],
    );
  }
}

