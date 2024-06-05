import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/beach_info/beach_info_page.dart';
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

  Marker toMarker() {
    return Marker(
      infoWindow: beach == null
          ? InfoWindow.noText
          : InfoWindow(
              title: beach!.name,
              onTap: () => NavigationService.instance
                  .push(BeachInfoPage(selectedBeach: beach!)),
            ),
      markerId: MarkerId(id),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          isCluster! ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed),
    );
  }
}
