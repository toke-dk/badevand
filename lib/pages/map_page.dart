import 'package:badevand/extenstions/postion_extension.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/beach.dart';
import '../providers/beaches_provider.dart';
import '../providers/google_markers_provider.dart';
import '../providers/user_position_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? get _userPosition =>
      context.watch<UserPositionProvider>().getPosition;

  static const LatLng centerOfDenmark = LatLng(56.000, 11.100);
  Set<Marker> markers = {};

  @override
  void initState() {
    _initializeMarkers(context, context.read<BeachesProvider>().getBeaches)
        .then((value) => setState(() {
              markers = value;
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationEnabled: _userPosition != null,
      initialCameraPosition: CameraPosition(
          target: _userPosition?.toLatLng ?? centerOfDenmark, zoom: 7),
      markers: context.read<GoogleMarkersProvider>().getMarkers,
    );
  }
}

Future<Set<Marker>> _initializeMarkers(
    BuildContext context, List<Beach> beaches) async {
  Set<Marker> markerList = {};

  final icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(32, 32)), 'assets/red_flag.png');

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
