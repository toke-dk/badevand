import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMarkersProvider extends ChangeNotifier {
  Set<Marker> _markers = {};

  Set<Marker> get getMarkers => _markers;

  void setMarkers(Set<Marker> markers) {
    _markers = markers;
    print("Has set markers");
    notifyListeners();
  }
}