import 'dart:convert';
import 'package:badevand/enums/sorting_values.dart';
import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/extenstions/postion_extension.dart';
import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/map_page.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/widgets/filter_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../models/beach.dart';
import '../models/sorting_option.dart';
import '../providers/beaches_provider.dart';
import '../providers/google_markers_provider.dart';
import '../providers/user_position_provider.dart';
import 'beach_info/beach_info_page.dart';
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

  bool get _isLoading => context.watch<LoadingProvider>().getIsAppLoading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
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
                              builder: (context) => const FilterBottomSheet());
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
          _isLoading == false
              ? const SizedBox.shrink()
              : Column(
                  children: List.generate(
                  4,
                  (int index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: ListTile(
                        leading: const Icon(Icons.flag),
                        trailing: const Icon(Icons.star),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                child: Container(
                              height: 12,
                              color: Colors.black,
                            )),
                            const Spacer(
                              flex: 4,
                            )
                          ],
                        ),
                        title: Container(
                          height: 16.0,
                          color: Colors.black,
                        ),
                      )),
                )),
          Expanded(
            child: ListView(
      
              shrinkWrap: true,
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
                      const Gap(6),
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
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            context
                                .read<HomeMenuIndexProvider>()
                                .setMapPageStartLocation(indexBeach.position);
                            context
                                .read<HomeMenuIndexProvider>()
                                .changeSelectedIndex(1);
                          },
                          icon: const Icon(Icons.pin_drop_outlined))
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}