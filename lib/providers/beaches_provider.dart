import 'dart:ui' as ui;

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:badevand/widgets/filter_bottom_sheet.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beach.dart';
import 'google_markers_provider.dart';

class BeachesProvider extends ChangeNotifier {
  List<Beach> _allBeaches = [];

  List<Beach> get getBeaches {
    return _allBeaches;
  }

  set setBeaches(List<Beach> newBeaches) {
    _allBeaches = newBeaches;
    notifyListeners();
  }

  Future<void> changeValueFavoriteBeach(Beach beachChange) async {
    if (!_allBeaches.contains(beachChange)) return;

    final int index = _allBeaches.indexOf(beachChange);
    final Beach beachToChange = _allBeaches[index];
    final bool previousValue = beachToChange.isFavourite;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> favouriteBeaches = prefs.getStringList('favourites') ?? [];

    if (previousValue) {
      prefs.setStringList(
          "favourites", favouriteBeaches..remove(beachChange.name.toLowerCase()));
    } else if (!previousValue) {
      prefs.setStringList(
          'favourites', favouriteBeaches..add(beachChange.name.toLowerCase()));
    }
    print("prefs ${prefs.getStringList('favourites')}");

    _allBeaches[index].isFavourite = !_allBeaches[index].isFavourite;

    notifyListeners();
  }

  void sortBeaches(SortingOption option) {
    _allBeaches = _allBeaches.sortBeach(option);

    // sorting first and then filtering
    _filterByMunicipality(_municipalityFilter);
    notifyListeners();
  }

  /// I always keep the [_municipalityFilter] so to know what filter is being
  /// used. Then when the beaches are sorted, it sorts all beaches and filter
  /// them afterwards. If it turns out that there is no filter, it does not
  /// filter them
  String _municipalityFilter = "alle";

  set setMunicipalityFilter(String municipality) {
    _municipalityFilter = municipality;
    _filterByMunicipality(_municipalityFilter);
    notifyListeners();
  }

  List<Beach> _filteredBeaches = [];

  List<Beach> get _getFilteredBeaches {
    // Initialize
    if (_filteredBeaches.isEmpty) {
      _filteredBeaches = _allBeaches;
    }

    return _filteredBeaches;
  }

  void _filterByMunicipality(String municipality) {
    if (municipality.toLowerCase() == "alle") {
      _filteredBeaches = _allBeaches;
    } else {
      _filteredBeaches = getBeaches.filterByMunicipality(municipality);
    }
    notifyListeners();
  }

  String _searchedValue = "";

  void setSearchedValue(String value) {
    _searchedValue = value;
    notifyListeners();
  }

  List<Beach> get getSearchedBeaches {
    return _filterBySearch(_searchedValue);
  }

  List<Beach> _filterBySearch(String searchValue) {
    if (searchValue == "") {
      return _getFilteredBeaches;
    } else {
      return _getFilteredBeaches.filterBySearch(searchValue);
    }
  }
}
