import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeMenuIndexProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get getSelectedIndex => _selectedIndex;

  void changeSelectedIndex(int newIndex) {
    _selectedIndex = newIndex;
    notifyListeners();
  }

  LatLng? _mapStartLocation;

  LatLng? get getMapStartLocation => _mapStartLocation;

  void setMapPageStartLocation(LatLng startLocation){
    _mapStartLocation = startLocation;
    notifyListeners();
  }
}
