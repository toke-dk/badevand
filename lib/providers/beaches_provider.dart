import 'dart:async';

import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:badevand/models/meteo/daily_meteo_data.dart';
import 'package:badevand/models/meteo/weather_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/beaches_from_csv/beaches_csv_api.dart';
import '../apis/meteomatics_api.dart';
import '../enums/sorting_values.dart';
import '../models/beach.dart';
import '../models/meteo/day_grouped_data.dart';
import '../models/sorting_option.dart';

class BeachesProvider extends ChangeNotifier {
  List<Beach> _allBeaches = [];

  Future<void> initBeaches () async {
    // getting them from asset file
    List<Beach> beaches = await getBeachDataFromAssetFile();
    // sorting them by name
    _allBeaches = beaches.sortBeach(SortingOption(value: SortingValues.name));

    _initCurrentSelectedBeach();

    notifyListeners();
  }

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
    final List<String> favouriteBeaches =
        prefs.getStringList('favourites') ?? [];

    if (previousValue) {
      prefs.setStringList(
          "favourites", favouriteBeaches..remove(beachChange.id));
    } else if (!previousValue) {
      prefs.setStringList('favourites', favouriteBeaches..add(beachChange.id));
    }

    _allBeaches[index].isFavourite = !_allBeaches[index].isFavourite;

    notifyListeners();
  }

  void sortBeaches(SortingOption option) {
    _allBeaches = _allBeaches.sortBeach(option);

    // sorting first and then filtering
    _filterByMunicipality(_municipalityFilter);
    notifyListeners();
  }

  /// Keep track of the currently selected beach

  Beach? _currentlySelectedBeach;

  Beach get getCurrentlySelectedBeach => _currentlySelectedBeach!;

  Future<void> _initCurrentSelectedBeach() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = _allBeaches.beachesFromId(prefs.getStringList("favourites") ?? []);
    final latest = _allBeaches.beachesFromId(prefs.getStringList("lastVisited") ?? []);

    if (favs.isNotEmpty) {
      _currentlySelectedBeach = favs.first;
    } else if (latest.isNotEmpty) {
      _currentlySelectedBeach = latest.first;
    } else {
      _currentlySelectedBeach = _allBeaches.first;
    }
    _updateDataForCurrentBeach();
  }

  Future<void> setCurrentlySelectedBeach(Beach newBeach) async {
    if (!_allBeaches.contains(newBeach)) return;

    // chaning isVisited list
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> idsVisited = prefs.getStringList("lastVisited") ?? [];

    // ensuring i remove the old visit
    idsVisited.removeWhere((id) => id == newBeach.id);

    idsVisited.insert(0, newBeach.id);

    if (idsVisited.length > 6) {
      idsVisited.removeLast();
    }
    prefs.setStringList("lastVisited", idsVisited);

    _currentlySelectedBeach = newBeach;

    _updateDataForCurrentBeach();
  }

  /// Grouped data

  List<DayGroupedMeteorologicalData> _dataForCurrentBeach = [];

  List<DayGroupedMeteorologicalData> get getDataForCurrentBeach {
    return _dataForCurrentBeach;
  }

  Future<void> _updateDataForCurrentBeach() async {
    final LatLng pos = getCurrentlySelectedBeach.position;

    final List<MeteorologicalData> meteoData = await getWeatherData(pos);

    final List<DailyForecastMeteoData> forecastMeteoData =
        await getDailyForecastData(pos);

    _dataForCurrentBeach = groupMeteoData(meteoData, forecastMeteoData);
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
