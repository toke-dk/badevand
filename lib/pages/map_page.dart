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
