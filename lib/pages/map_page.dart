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
  List<Beach> get _beaches => context.watch<BeachesProvider>().getBeaches;

  Position? get _userPosition =>
      context.watch<UserPositionProvider>().getPosition;

  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController
        ?.dispose(); // If using Completer (replace with your disposal logic)
    _mapController = null; // If storing directly from onMapCreated
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: _userPosition != null,
      myLocationEnabled: _userPosition != null,
      initialCameraPosition: CameraPosition(
          target: _userPosition?.toLatLng ?? _beaches.first.position, zoom: 13),
      markers: context.watch<GoogleMarkersProvider>().getMarkers,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}