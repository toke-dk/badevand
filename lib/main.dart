import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/pages/home_page.dart';
import 'package:badevand/pages/map_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/google_markers_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

