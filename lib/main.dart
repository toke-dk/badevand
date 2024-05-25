import 'dart:convert';
import 'dart:io';

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:badevand/extenstions/http_override.dart';
import 'package:badevand/models/ad_state.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/all_pages.dart';
import 'package:badevand/pages/home_page.dart';
import 'package:badevand/pages/map_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/google_markers_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/providers/user_position_provider.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'enums/sorting_values.dart';
import 'models/sorting_option.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      getBeachData().then((List<dynamic> result) =>
          handleBeachData(context, beachDataResults: result));
    });

    super.initState();
  }

  BannerAd? banner;

  @override
  void didChangeDependencies() {
    final adState = Provider.of<AdState>(context);

    adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            listener: adState.bannerAdListener,
            request: AdRequest())
          ..load();
      });
    });
    super.didChangeDependencies();
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
          bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.water), label: "Liste"),
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
                SizedBox(height: 10,),
                if (banner == null)
                  SizedBox(
                    height: 50,
                  )
                else
                  Container(
                    height: 50,
                    child: AdWidget(
                      ad: banner!,
                    ),
                  ),
                SizedBox(height: 10,),

                Expanded(
                    child: kAllScreens.elementAt(_selectedMenuIndex)(context)),
              ],
            ),
          )),
    );
  }
}

Future<void> handleBeachData(BuildContext context,
    {required List<dynamic> beachDataResults}) async {
  bool getIsFavourite(List<String> favouriteBeaches, String beachName) {
    if (favouriteBeaches.contains(beachName.toLowerCase())) {
      return true;
    } else {
      return false;
    }
  }

  List<dynamic> result = [];
  context.read<LoadingProvider>().toggleAppLoadingState(true);
  await getBeachData().then((List<dynamic> value) {
    result = value;
    context.read<LoadingProvider>().toggleAppLoadingState(false);
  });

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String> favouriteBeaches = prefs.getStringList('favourites') ?? [];

  context.read<BeachesProvider>().setBeaches = result
      .map((e) => Beach.fromMap(
          e, getIsFavourite(favouriteBeaches, e["name"].toString())))
      .toList()
      .sortBeach(SortingOption(value: SortingValues.name));
  await context.read<GoogleMarkersProvider>().initMarkers(context);
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
