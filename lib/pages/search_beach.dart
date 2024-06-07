import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/enums/weather_types.dart';
import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:badevand/providers/loading_provider.dart';
import 'package:badevand/widgets/filter_bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/beach.dart';
import '../providers/beaches_provider.dart';
import 'beach_info/beach_info_page.dart';
import 'package:badges/badges.dart' as badges;

import 'home_page.dart';


class SearchBeachPage extends StatefulWidget {
  const SearchBeachPage({super.key});

  @override
  State<SearchBeachPage> createState() => _SearchBeachPageState();
}

class _SearchBeachPageState extends State<SearchBeachPage> {
  List<Beach> get _beachesToDisplay =>
      context.watch<BeachesProvider>().getSearchedBeaches;

  void _filterSearchedBeaches(String value) {
    context.read<BeachesProvider>().setSearchedValue(value);
  }

  bool get _isLoading => context.watch<LoadingProvider>().getIsAppLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        onChanged: (text) {
          _filterSearchedBeaches(text);
        },
        appBarBuilder: (context) {
          return AppBar(
            title: Text("Find badested"),
            actions: [
              AppBarSearchButton(),
            ],
          );
        },
        animation: AppBarAnimationSlideLeft.call,

      ),
      body: Column(
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

                final BeachSpecifications? specsToday = indexBeach.getSpecsOfToday;

                return ListTile(
                  trailing: indexBeach.createFavoriteIcon(context),
                  onTap: () {
                    context.read<BeachesProvider>().setCurrentlySelectedBeach(indexBeach);
                    Navigator.pop(context);
                  },
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
                  leading: specsToday?.waterQualityType.flag,
                  subtitle: specsToday == null ? null : Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: Colors.blue[800],
                      ),
                      const Gap(4),
                      Text(specsToday.waterTemperature.asCelsiusTemperature),
                      const Gap(10),
                      specsToday.weatherType?.icon ??
                          const SizedBox.shrink(),
                      const Gap(8),
                      Text(specsToday.airTemperature.asCelsiusTemperature),
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