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
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

Future<Set<Marker>> _initializeMarkers(
    BuildContext context, List<Beach> beaches) async {
  Set<Marker> markerList = {};

  final Uint8List greenFlag =
      await getBytesFromAsset('assets/green_flag.png', 150);
  final Uint8List redFlag = await getBytesFromAsset('assets/red_flag.png', 150);
  final Uint8List yellowFlag =
      await getBytesFromAsset('assets/yellow_flag.png', 150);
  final Uint8List greyFlag =
      await getBytesFromAsset('assets/grey_flag.png', 150);

  final BitmapDescriptor greenIcon = BitmapDescriptor.fromBytes(greenFlag);
  final BitmapDescriptor redIcon = BitmapDescriptor.fromBytes(redFlag);
  final BitmapDescriptor yellowIcon = BitmapDescriptor.fromBytes(yellowFlag);
  final BitmapDescriptor greyIcon = BitmapDescriptor.fromBytes(greyFlag);

  for (Beach indexBeach in beaches) {
    BitmapDescriptor iconToUse() {
      final BeachSpecifications? specs = indexBeach.getSpecsOfToday;
      if (specs == null) return greyIcon;
      switch (specs.waterQualityType) {
        case WaterQualityTypes.goodQuality:
          return greenIcon;
        case WaterQualityTypes.badQuality:
          return redIcon;
        case WaterQualityTypes.noWarning:
          return yellowIcon;
        case WaterQualityTypes.closed:
          return greyIcon;
      }
    }

    markerList.add(Marker(
        markerId: MarkerId(indexBeach.name),
        position: indexBeach.position,
        infoWindow: InfoWindow(
            onTap: () => NavigationService.instance
                .push(BeachInfoPage(selectedBeach: indexBeach)),
            title: indexBeach.name,
            snippet: indexBeach.comments != "" ? indexBeach.comments : null)));
  }
  return markerList;
}

Future<Set<Marker>> googleMarkers(List<Beach> beaches, double currentZoom,
    Map<int, BitmapDescriptor> icons) async {
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
    googleMarkers.add(await convertToMarker(cluster, icons));
  }

  return googleMarkers.toSet();
}

Future<BitmapDescriptor> createBitMapFromAsset(String asset, int size) async {
  return BitmapDescriptor.fromBytes(await getBytesFromAsset(asset, size));
}
