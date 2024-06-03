import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../enums/sorting_values.dart';
import '../enums/water_quality.dart';
import '../models/beach.dart';
import '../models/sorting_option.dart';
import '../widgets/filter_bottom_sheet.dart';

extension ListOfBeachExtension on List<Beach> {
  List<String> get getBeachesMunicipalityStrings =>
      map((Beach beach) => beach.municipality).toSet().toList();

  List<Beach> sortBeach(SortingOption option) {
    LatLng? userPosition = option.userPosition;
    List<Beach> beachesToReturn = this;
    switch (option.value) {
      case SortingValues.name:
        beachesToReturn = this..sort((a, b) => a.name.compareTo(b.name));
      case SortingValues.distance:
        if (userPosition == null) return this;
        beachesToReturn = this
          ..sort((a, b) => a
              .distanceInKm(userPosition)!
              .compareTo(b.distanceInKm(userPosition)!));
      case SortingValues.waterQuality:
        List<Beach> goodQual =
        getBeachesFromQuality(WaterQualityTypes.goodQuality);
        List<Beach> badQual =
        getBeachesFromQuality(WaterQualityTypes.badQuality);
        List<Beach> noWarn = getBeachesFromQuality(WaterQualityTypes.noWarning);
        List<Beach> closed = getBeachesFromQuality(WaterQualityTypes.closed);
        beachesToReturn = [...goodQual, ...badQual, ...noWarn, ...closed];
      case SortingValues.municipalityName:
        beachesToReturn = this
          ..sort((a, b) => a.municipality.compareTo(b.municipality));
    }
    if (option.isAscending == false) {
      beachesToReturn = beachesToReturn.reversed.toList();
    }
    return beachesToReturn;
  }

  List<Beach> getBeachesFromQuality(WaterQualityTypes quality) {
    return where((beach) => beach.getSpecsOfToday?.waterQualityType == quality)
        .toList();
  }

  List<Beach> filterByMunicipality(String municipality) {
    List<Beach> beachesToReturn =  where((beach) => beach.municipality.toLowerCase() == municipality.toLowerCase()).toList();
    print("those to filter ${beachesToReturn.map((e) => e.municipality)}");
    return beachesToReturn;
  }

  List<Beach> filterBySearch(String searchValue) {
    return where(
            (item) => item.name.toLowerCase().contains(searchValue.toLowerCase()))
        .toList();
  }

  List<Beach> get getFavouriteBeaches => where((e) => e.isFavourite).toList();
}