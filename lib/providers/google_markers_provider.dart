import 'dart:ui' as ui;

import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/extenstions/cluster_extension.dart';
import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/beach_info/beach_info_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';
import 'home_menu_index.dart';

class IconMapsProvider extends ChangeNotifier {
  Map<int, BitmapDescriptor> _iconMap = {};

  Map<int, BitmapDescriptor> get getIconMap => _iconMap;

  Future<void> initMarkers(BuildContext context) async {
    _iconMap = await _initializeMarkers(
        context, context.read<BeachesProvider>().getBeaches);
    print("initing");
    notifyListeners();
  }
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<Map<int, BitmapDescriptor>> _initializeMarkers(
    BuildContext context, List<Beach> beaches) async {
  int initialSize = 150;
  return {
    1: await createBitMapFromAsset(
        "assets/cluster_icons/p1.png", initialSize),
    5: await createBitMapFromAsset(
        "assets/cluster_icons/p5.png", initialSize),
    10: await createBitMapFromAsset(
        "assets/cluster_icons/p10.png", initialSize),
    50: await createBitMapFromAsset(
        "assets/cluster_icons/p50.png", initialSize),
    100: await createBitMapFromAsset(
        "assets/cluster_icons/p100.png", initialSize),
  };
}

Future<Set<Marker>> googleMarkers(List<Beach> beaches, double currentZoom,
    Map<int, BitmapDescriptor> icons, BuildContext context) async {
  final List<MapMarker> markers = [];

  for (Beach indexBeach in beaches) {
    markers.add(
      MapMarker(
        id: indexBeach.id,
        position: indexBeach.position,
        beach: indexBeach,
      ),
    );
  }

  Fluster<MapMarker> fluster = Fluster<MapMarker>(
      minZoom: 0,
      maxZoom: 20,
      radius: 150,
      extent: 1100,
      nodeSize: 64,
      points: markers,
      createCluster:
          (BaseCluster? cluster, double? longitude, double? latitude) {
        return MapMarker(
          id: cluster!.id.toString(),
          position: LatLng(latitude!, longitude!),
          isCluster: cluster.isCluster,
          clusterId: cluster.id,
          pointsSize: cluster.pointsSize,
          childMarkerId: cluster.childMarkerId,
        );
      });

  final List<Marker> googleMarkers = [];

  for (final cluster
      in fluster.clusters([-180, -85, 180, 85], currentZoom.toInt())) {
    googleMarkers.add(await convertToMarker(cluster, icons, context));
  }

  return googleMarkers.toSet();
}

Future<BitmapDescriptor> createBitMapFromAsset(String asset, int size) async {
  return BitmapDescriptor.fromBytes(await getBytesFromAsset(asset, size));
}
