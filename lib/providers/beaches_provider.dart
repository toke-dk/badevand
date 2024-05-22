import 'dart:ui' as ui;

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/widgets/filter_bottom_sheet.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';
import 'google_markers_provider.dart';

class BeachesProvider extends ChangeNotifier {
  List<Beach> _beaches = [];

  List<Beach> get getBeaches => _beaches;

  set setBeaches(List<Beach> newBeaches) {
    _beaches = newBeaches;
    notifyListeners();
  }

  set changeValueFavoriteBeach(Beach beachChange) {
    if (!_beaches.contains(beachChange)) return;

    final int index = _beaches.indexOf(beachChange);
    _beaches[index].isFavourite = !_beaches[index].isFavourite;
    notifyListeners();
  }

  void sortBeaches(SortingOption option, LatLng userPosition) {
    _beaches = option.sortBeach(_beaches, option, userPosition);
  }



}

