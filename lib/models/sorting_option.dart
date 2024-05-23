import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../enums/sorting_values.dart';

class SortingOption {
  SortingValues value;
  bool isAscending;
  LatLng? userPosition;

  SortingOption({required this.value, this.isAscending = true, this.userPosition});

  get defaultAscend {
    isAscending = true;
  }

  get toggleAscend {
    isAscending = !isAscending;
  }
}