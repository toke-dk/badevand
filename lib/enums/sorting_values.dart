enum SortingValues { name, distance, waterQuality, municipalityName }

extension SortingValuesExtension on SortingValues {
  String get name {
    switch (this) {
      case SortingValues.name:
        return "Navn";
      case SortingValues.distance:
        return "Afstand";
      case SortingValues.waterQuality:
        return "Vandkvalitet";
      case SortingValues.municipalityName:
        return "Kommune";
    }
  }
}