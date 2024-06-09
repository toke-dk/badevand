import 'dart:async';
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
    if (widget.preLocatedPosition != null) {
      return 15.3;
    }
    if (_userPosition != null) return 10.2;
    return 7;
  }

  late double _currentZoom;

  @override
  void didChangeDependencies() {
    _currentZoom = _getStartZoom;
    super.didChangeDependencies();
  }

  late List<Beach> _placesToShowMarkers =
      context.read<BeachesProvider>().getBeaches;

  Set<Marker> _markers = {};

  Map<int, BitmapDescriptor> icons = {};

  Future<void> initializeIcons() async {
    int initialSize = 150;
    icons = {
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

  late List<Beach> _allBeaches = context.read<BeachesProvider>().getBeaches;

  GoogleMapController? _controller;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeIcons();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _updateVisibleMarkers() async {
    print("update");

    LatLngBounds visibleRegion = await _controller!.getVisibleRegion();

    final List<Beach> visibleBeaches =
        _allBeaches.where((b) => visibleRegion.contains(b.position)).toList();

    _placesToShowMarkers = visibleBeaches;

    final gMarks = await googleMarkers(
        _placesToShowMarkers, _currentZoom, icons, context);

    setState(() {
      _markers = gMarks.toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onCameraIdle: () => _updateVisibleMarkers(),
          onCameraMove: (CameraPosition newPos) {
            // waiting to set the state for the camera idle to improve
            // performance
            _currentZoom = newPos.zoom;
          },
          onMapCreated: (controller) {
            _controller = controller;
            _updateVisibleMarkers();
          },
          mapType: _currentMapType,
          myLocationEnabled: _userPosition != null,
          initialCameraPosition:
              CameraPosition(target: _getStartPosition, zoom: _getStartZoom),
          markers: _markers,
        ),
        Positioned(
          bottom: 5,
          left: 5,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _currentMapType = (_currentMapType == MapType.normal)
                    ? MapType.satellite
                    : MapType.normal;
              });
            },
            child: const Icon(Icons.layers),
          ),
        )
      ],
    );
  }
}
