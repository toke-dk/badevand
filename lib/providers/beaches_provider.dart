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
  List<Beach> _allBeaches = [];

  List<Beach> get getBeaches {
    print(_allBeaches.map((e) => e.name));
    return _allBeaches;
  }

  set setBeaches(List<Beach> newBeaches) {
    _allBeaches = newBeaches;
    notifyListeners();
  }

  set changeValueFavoriteBeach(Beach beachChange) {
    if (!_allBeaches.contains(beachChange)) return;

    final int index = _allBeaches.indexOf(beachChange);
    _allBeaches[index].isFavourite = !_allBeaches[index].isFavourite;
    notifyListeners();
  }

  List<Beach> _filteredBeaches = [];

  List<Beach> get getFilteredBeaches {
    if (_filteredBeaches.isEmpty) {
      _filteredBeaches = _allBeaches;
      return _filteredBeaches;
    }
    print("no");
    return _filteredBeaches;
  }

  void sortBeaches(SortingOption option, LatLng? userPosition) {
    _filteredBeaches = _filteredBeaches.sortBeach(option, userPosition);
    notifyListeners();
  }




}

