import 'package:badevand/models/navigator_service.dart';
import 'package:badevand/pages/beach_info/beach_info_page.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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

Future<Marker> convertToMarker(
    MapMarker marker, Map<int, BitmapDescriptor> icons, BuildContext context) async {
  return Marker(
    infoWindow: marker.beach == null
        ? InfoWindow.noText
        : InfoWindow(
            title: marker.beach!.name,
            snippet: "Tryk for at se mere",
            onTap: () {
              context.read<BeachesProvider>().setCurrentlySelectedBeach(marker.beach!);
              NavigationService.instance
                .push(BeachInfoPage());
            },
          ),
    markerId: MarkerId(marker.id),
    position: marker.position,
    icon: await getIcon(marker.pointsSize ?? 1, icons),
  );
}

BitmapDescriptor getIcon(int pointSize, Map<int, BitmapDescriptor> icons) {
  if (pointSize >= 100) {
    return icons[100]!;
  } else if (pointSize >= 50) {
    return icons[50]!;
  } else if (pointSize >= 10) {
    return icons[10]!;
  } else if (pointSize >= 5) {
    return icons[5]!;
  } else if (pointSize > 1) {
    return icons[1]!;
  }
  return BitmapDescriptor.defaultMarker;
}
