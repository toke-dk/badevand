import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/beach_info/beach_info_page.dart';
import 'package:badevand/providers/google_markers_provider.dart';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/beach.dart';

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final Beach? beach;

  MapMarker({
    required this.id,
    required this.position,
    this.beach,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
    markerId: id,
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    childMarkerId: childMarkerId,
  );
}

Future<Marker> convertToMarker(MapMarker marker) async {
  return Marker(
    infoWindow: marker.beach == null
        ? InfoWindow.noText
        : InfoWindow(
      title: marker.beach!.name,
      onTap: () =>
          NavigationService.instance
              .push(BeachInfoPage(selectedBeach: marker.beach!)),
    ),
    onTap: () => print("size: ${getIcon(marker.pointsSize ?? 1)}"),
    markerId: MarkerId(marker.id),
    position: marker.position,
    icon: await getIcon(marker.pointsSize ?? 1),
  );
}

Future<BitmapDescriptor> getIcon(int pointSize) async {
  BitmapDescriptor? toReturn;
  final int size = 150;

  if (pointSize >= 100) {
    toReturn = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/cluster_icons/p100.png", size));
  } else if (pointSize >= 50) {
    toReturn = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/cluster_icons/p50.png", size));
  } else if (pointSize >= 10) {
    toReturn = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/cluster_icons/p10.png", size));
  } else if (pointSize >= 5) {
    toReturn = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/cluster_icons/p5.png", size));
  } else if (pointSize > 1) {
    toReturn = BitmapDescriptor.fromBytes(
        await getBytesFromAsset("assets/cluster_icons/p1.png", size));
  }
  return toReturn ?? BitmapDescriptor.defaultMarker;
}