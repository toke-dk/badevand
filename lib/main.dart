import 'dart:convert';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/postion_extension.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/pages/beach_info_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/google_markers_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (BuildContext context) => BeachesProvider()),
      ChangeNotifierProvider(
          create: (BuildContext context) => GoogleMarkersProvider()),
      ChangeNotifierProvider(
          create: (BuildContext context) => UserPositionProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedMenuIndex = 0;

  Future<void> _determinePosition() async {
    Position? position;

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();

    context.read<UserPositionProvider>().setPosition = position;
  }

  Future<void> _initializeMarkers(List<Beach> beaches) async {
    Set<Marker> markerList = {};

    for (Beach indexBeach in beaches) {
      final view = ui.PlatformDispatcher.instance.views.first;
      final icon = await indexBeach.getSpecsOfToday.waterQualityType.flag
          .toBitmapDescriptor(
              imageSize: view.physicalSize * 1.3, waitToRender: Duration.zero);

      markerList.add(Marker(
          markerId: MarkerId(indexBeach.name),
          position: indexBeach.position,
          icon: icon,
          infoWindow: InfoWindow(
              title: indexBeach.name,
              snippet:
                  indexBeach.comments != "" ? indexBeach.comments : null)));
    }
    context.read<GoogleMarkersProvider>().setMarkers(markerList);
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Beach> beaches = context.watch<BeachesProvider>().getBeaches;

    // initializing the google maps markers
    if (beaches.isNotEmpty)
      _initializeMarkers(context.watch<BeachesProvider>().getBeaches);

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
          body: _pages.elementAt(_selectedMenuIndex)),
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

    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Den bedste badevandsapp"),
          OutlinedButton(
              onPressed: () async {
                List<dynamic> result = await getBeachData();

                context
                    .read<BeachesProvider>()
                    .setBeaches(result.map((e) => Beach.fromMap(e)).toList());
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        BeachInfoPage(selectedBeach: indexBeach))),
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
                    Text("${indexBeach.getSpecsOfToday.airTemperature} \u2103")
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

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Beach> get _beaches => context.watch<BeachesProvider>().getBeaches;

  Position? get _userPosition =>
      context.watch<UserPositionProvider>().getPosition;

  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController
        ?.dispose(); // If using Completer (replace with your disposal logic)
    _mapController = null; // If storing directly from onMapCreated
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: _userPosition != null,
      myLocationEnabled: _userPosition != null,
      initialCameraPosition: CameraPosition(
          target: _userPosition?.toLatLng ?? _beaches.first.position, zoom: 13),
      markers: context.watch<GoogleMarkersProvider>().getMarkers,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}
