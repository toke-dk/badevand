import 'dart:io';

import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:badevand/extenstions/http_override.dart';
import 'package:badevand/firebase_options.dart';
import 'package:badevand/models/ad_state.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/all_pages.dart';
import 'package:badevand/pages/home_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/google_markers_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apis/beaches_from_csv/beaches_csv_api.dart';
import 'enums/sorting_values.dart';
import 'models/sorting_option.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final initFuture = MobileAds.instance.initialize();
  final AdState adState = AdState(initFuture);

  HttpOverrides.global = MyHttpOverrides();

  runApp(Provider.value(
      value: adState,
      builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (BuildContext context) => BeachesProvider()),
              ChangeNotifierProvider(
                  create: (BuildContext context) => GoogleMarkersProvider()),
              ChangeNotifierProvider(
                  create: (BuildContext context) => UserPositionProvider()),
              ChangeNotifierProvider(
                  create: (BuildContext context) => HomeMenuIndexProvider()),
              ChangeNotifierProvider(
                  create: (BuildContext context) => LoadingProvider()),
            ],
            child: const MyApp(),
          )));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int get _selectedMenuIndex =>
      context.watch<HomeMenuIndexProvider>().getSelectedIndex;

  List<Beach> get beaches => context.read<BeachesProvider>().getBeaches;

  late SharedPreferences prefs;

  Future<SharedPreferences> get setPrefs async =>
      prefs = await SharedPreferences.getInstance();

  late Beach _selectedBeach =
      context.watch<BeachesProvider>().getCurrentlySelectedBeach;

  @override
  void initState() {
    _determinePosition();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeDateFormatting("da", "DA");
      _initBeaches();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dansk Badevand',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
          drawer: Drawer(),
          appBar: AppBar(
            actions: [
              _selectedBeach.createFavoriteIcon(context,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => NavigationService.instance
                    .push(SearchBeachPage())
                    .then((_) =>
                        context.read<BeachesProvider>().setSearchedValue("")),
              )
            ],
            title: Text(_selectedBeach.name),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.sunny), label: "Udsigt"),
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
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: kAllScreens.elementAt(_selectedMenuIndex)(context)),
              ],
            ),
          )),
    );
  }

  Future<void> _initBeaches() async {
    List<Beach> beaches = await getBeachDataFromAssetFile(context);

    context.read<BeachesProvider>().setBeaches =
        beaches.sortBeach(SortingOption(value: SortingValues.name));

    await context.read<GoogleMarkersProvider>().initMarkers(context);
  }

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
}
