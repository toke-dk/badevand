import 'package:badevand/pages/home_page.dart';
import 'package:badevand/pages/map_page.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

final List<Widget Function(BuildContext context)> kAllScreens = [
  (context) => Home(),
  (context) => MapPage(
        preLocatedPosition:
            context.watch<HomeMenuIndexProvider>().getMapStartLocation,
      ),
];
