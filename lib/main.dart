import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/models/beach.dart';
import 'package:flutter/material.dart';
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
  List<dynamic> beachesRaw = [];

    @override
  Widget build(BuildContext context) {
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
        body: Column(
          children: [
            const Text("Den bedste badevandsapp"),
            OutlinedButton(
                onPressed: () async {
                  beachesRaw = await getBeachData();

                  setState(()  {
                  });
                },
                child: Text("Get data (${beachesRaw.isNotEmpty ? 'hasData' : "hasNotData"})")),
            OutlinedButton(
                onPressed: () async {
                 print((beachesRaw).map((e) => Beach.fromMap(e)));
                },
                child: const Text("Convert to dart class"))
          ],
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
