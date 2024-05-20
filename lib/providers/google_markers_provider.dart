import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/widgets/widget_to_map_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

Future<Set<Marker>> _initializeMarkers(
    BuildContext context, List<Beach> beaches) async {
  Set<Marker> markerList = {};

  final Uint8List markerIcon = await getBytesFromAsset('assets/green_flag.png', 150);

  final BitmapDescriptor icon = BitmapDescriptor.fromBytes(markerIcon);

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
