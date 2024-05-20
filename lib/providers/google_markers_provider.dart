import 'dart:ui' as ui;

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';

class GoogleMarkersProvider extends ChangeNotifier {
  Set<Marker> _markers = {};

  Set<Marker> get getMarkers => _markers;

  Future<void> initMarkers(BuildContext context) async {
    final Set<Marker> markers = await _initializeMarkers(
        context, context.read<BeachesProvider>().getBeaches);
    _markers = markers;
    print("initing");
    notifyListeners();
  }
}

Future<Set<Marker>> _initializeMarkers(
    BuildContext context, List<Beach> beaches) async {
  Set<Marker> markerList = {};

  final icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(32, 32)), 'assets/red_flag.png');

  for (Beach indexBeach in beaches) {

    markerList.add(Marker(
        markerId: MarkerId(indexBeach.name),
        position: indexBeach.position,
        icon: icon,
        infoWindow: InfoWindow(
            title: indexBeach.name,
            snippet: indexBeach.comments != "" ? indexBeach.comments : null)));
  }
  return markerList;
}
