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
  const MapPage({super.key, this.preLocatedPosition});

  final LatLng? preLocatedPosition;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? get _userPosition =>
      context.watch<UserPositionProvider>().getPosition;

  static const LatLng centerOfDenmark = LatLng(56.000, 11.100);

  MapType _currentMapType = MapType.normal;

  LatLng get _getStartPosition {
    if (widget.preLocatedPosition != null) return widget.preLocatedPosition!;
    if (_userPosition != null) return _userPosition!.toLatLng;
    return centerOfDenmark;
  }

  double get _getStartZoom {
    if (widget.preLocatedPosition != null) return 14.8;
    if (_userPosition != null) return 10.2;
    return 7;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: _currentMapType,
          myLocationEnabled: _userPosition != null,
          initialCameraPosition: CameraPosition(
              target: _getStartPosition, zoom: _getStartZoom),
          markers: context.read<GoogleMarkersProvider>().getMarkers,
        ),
        Positioned(bottom: 5, left: 5,child: FloatingActionButton(onPressed: (){
          setState(() {
            _currentMapType = (_currentMapType == MapType.normal) ? MapType.satellite : MapType.normal;
          });
        }, child: const Icon(Icons.layers),),)
      ],
    );
  }
}
