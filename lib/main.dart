import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/all_pages.dart';
import 'package:badevand/pages/home_page.dart';
import 'package:badevand/pages/map_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/google_markers_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (BuildContext context) => BeachesProvider()),
      ChangeNotifierProvider(
          create: (BuildContext context) => GoogleMarkersProvider()),
      ChangeNotifierProvider(
          create: (BuildContext context) => UserPositionProvider()),
      ChangeNotifierProvider(
          create: (BuildContext context) => HomeMenuIndexProvider()),
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
  int get _selectedMenuIndex =>
      context.watch<HomeMenuIndexProvider>().getSelectedIndex;

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

  List<Beach> get beaches => context.read<BeachesProvider>().getBeaches;

  late SharedPreferences prefs;

  Future<SharedPreferences> get setPrefs async =>
      prefs = await SharedPreferences.getInstance();

  @override
  void initState() {
    _determinePosition();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeDateFormatting("da", "DA");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: NavigationService.instance.navigatorKey,
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
              onTap: (int newIndex) {
                if (context.read<HomeMenuIndexProvider>().getSelectedIndex ==
                    0) {
                  context.read<BeachesProvider>().setSearchedValue("");
                }
                context
                    .read<HomeMenuIndexProvider>()
                    .changeSelectedIndex(newIndex);
              }),
          body: kAllScreens.elementAt(_selectedMenuIndex)(context)),
    );
  }
}
