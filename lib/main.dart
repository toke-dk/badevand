import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/models/beach.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;

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

    return MaterialApp(
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<dynamic> _beachesRaw = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Den bedste badevandsapp"),
        OutlinedButton(
            onPressed: () async {
              _beachesRaw = await getBeachData();

              setState(() {});
            },
            child: Text(
                "Get data (${_beachesRaw.isNotEmpty ? 'hasData' : "hasNotData"})")),
        OutlinedButton(
            onPressed: () async {
              print((_beachesRaw).map((e) => Beach.fromMap(e)));
            },
            child: const Text("Convert to dart class")),
        Column(
          children: List.generate(_beachesRaw.length, (index) {
            final Beach indexBeach = Beach.fromMap(_beachesRaw[index]);
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
    return const Column(
      children: [
        Text("data")
      ],
    );
  }
}

