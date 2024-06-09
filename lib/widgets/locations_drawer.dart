import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beach.dart';
import '../providers/beaches_provider.dart';
import '../providers/home_menu_index.dart';

class FavouriteLocationsInDrawer extends StatefulWidget {
  const FavouriteLocationsInDrawer({super.key});

  @override
  State<FavouriteLocationsInDrawer> createState() =>
      _FavouriteLocationsInDrawerState();
}

class _FavouriteLocationsInDrawerState
    extends State<FavouriteLocationsInDrawer> {
  late TextTheme _textTheme = Theme.of(context).textTheme;

  late List<Beach> _beaches = context.read<BeachesProvider>().getBeaches;

  SharedPreferences? prefs;

  List<Beach> get _favouriteBeaches => _beaches.getFavouriteBeaches;

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    _initPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _favouriteBeaches.isEmpty
        ? Center(
            child: Column(
              children: [
                Text("Gem dine steder her"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tryk på ",
                      style: _textTheme.labelMedium,
                    ),
                    Icon(
                      Icons.star_outline,
                      size: _textTheme.labelMedium!.fontSize,
                    ),
                    Text(" ikonet for at tilføje som favorit",
                        style: _textTheme.labelMedium)
                  ],
                ),
              ],
            ),
          )
        : Column(
            children: _favouriteBeaches.map((indexBeach) {
              return ListTile(
                title: Text(indexBeach.name),
                trailing: indexBeach.createFavoriteIcon(context),
                onTap: () {
                  context.read<HomeMenuIndexProvider>().changeSelectedIndex(0);
                  context
                      .read<BeachesProvider>()
                      .setCurrentlySelectedBeach(indexBeach);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          );
  }
}
