import 'dart:convert';
import 'package:badevand/enums/sorting_values.dart';
import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/extenstions/postion_extension.dart';
import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/map_page.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/widgets/filter_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beach.dart';
import '../providers/beaches_provider.dart';
import '../providers/google_markers_provider.dart';
import '../providers/user_position_provider.dart';
import 'beach_info_page.dart';
import 'package:badges/badges.dart' as badges;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Beach> get beaches => context.watch<BeachesProvider>().getBeaches;

  Position? get _userPosition =>
      context.read<UserPositionProvider>().getPosition;

  List<Beach> get _beachesToDisplay =>
      context.watch<BeachesProvider>().getSearchedBeaches;

  void _filterSearchedBeaches(String value) {
    context.read<BeachesProvider>().setSearchedValue(value);
  }

  bool getIsFavourite(List<String> favouriteBeaches, String beachName) {
    if (favouriteBeaches.contains(beachName.toLowerCase())) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text("Den bedste badevandsapp"),
          OutlinedButton(
              onPressed: () async {
                List<dynamic> result = await getBeachData();

                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final List<String> favouriteBeaches =
                    prefs.getStringList('favourites') ?? [];

                context.read<BeachesProvider>().setBeaches = result
                    .map((e) => Beach.fromMap(e,
                        getIsFavourite(favouriteBeaches, e["name"].toString())))
                    .toList().sortBeach(SortingOption(value: SortingValues.name), _userPosition?.toLatLng);
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
                    padding: const EdgeInsets.only(right: 10, left: 8),
                    child: FittedBox(
                        child: badges.Badge(
                      position: badges.BadgePosition.topEnd(top: 6, end: 6),
                      child: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) => FilterBottomSheet());
                        },
                      ),
                    ))),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onChanged: (value) {
                _filterSearchedBeaches(value);
              },
            ),
          ),
          const Gap(10),
          _beachesToDisplay.getFavouriteBeaches.isEmpty
              ? SizedBox.shrink()
              : ExpansionPanelList(
                  children: [
                    ExpansionPanel(
                        headerBuilder: (context, _) => Text("Favoritter"),
                        body: Text("fe"))
                  ],
                ),
          Column(
            children: List.generate(_beachesToDisplay.length, (index) {
              final Beach indexBeach = _beachesToDisplay[index];
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
                    Text(
                      indexBeach.municipality,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
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
                        .getSpecsOfToday.airTemperature.asCelsiusTemperature),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          context
                              .read<HomeMenuIndexProvider>()
                              .setMapPageStartLocation(indexBeach.position);
                          context
                              .read<HomeMenuIndexProvider>()
                              .changeSelectedIndex(1);
                        },
                        icon: Icon(Icons.pin_drop_outlined))
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
