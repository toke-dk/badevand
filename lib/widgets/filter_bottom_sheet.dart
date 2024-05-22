import 'package:badevand/models/beach.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/user_position_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<Beach> get _beaches => context.watch<BeachesProvider>().getBeaches;

  List<String> get _beachesMunicipalityStrings =>
      _beaches.getBeachesMunicipalityStrings;

  String? _selectedMunicipality;

  late List<SortingOption> _sortingOptions;
  late SortingOption _selectedSortingOption;
  Position? get userPosition =>
      context.read<UserPositionProvider>().getPosition;

  @override
  void didChangeDependencies() {
    _sortingOptions = [
      SortingOption(value: SortingValues.name, isAscending: true),
      SortingOption(value: SortingValues.municipalityName, isAscending: null),
      SortingOption(value: SortingValues.waterQuality, isAscending: null),
    ];
    if (userPosition != null) {
      _sortingOptions.add(
          SortingOption(value: SortingValues.distance, isAscending: null));
    }

    _selectedSortingOption = _sortingOptions.first;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(_beachesMunicipalityStrings);
    if (_selectedMunicipality == null) {
      setState(() {
        _selectedMunicipality = _beachesMunicipalityStrings.first;
      });
    }

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              const Text("Kommune"),
              const Gap(15),
              DropdownButton<String>(
                menuMaxHeight: 350,
                items: _beachesMunicipalityStrings
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (newVal) {
                  if (newVal == null) return;
                  setState(() {
                    _selectedMunicipality = newVal;
                  });
                },
                value: _selectedMunicipality,
              )
            ],
          ),
          Row(
            children: [
              const Text("Sorter efter"),
              const Gap(15),
              DropdownButton<SortingOption>(
                menuMaxHeight: 350,
                items: _sortingOptions
                    .map((e) => DropdownMenuItem<SortingOption>(
                          value: e,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            // Adjust padding as needed
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.value.name),
                                Gap(20),
                                e.isAscending == true
                                    ? const Icon(Icons.arrow_upward)
                                    : const SizedBox.shrink(),
                                e.isAscending == false
                                    ? const Icon(Icons.arrow_downward)
                                    : const SizedBox.shrink()
                                // Trailing icon (optional)
                              ],
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (newOption) {
                  if (newOption == null) return;
                  setState(() {
                    if (_selectedSortingOption.value == newOption.value) {
                      _selectedSortingOption.toggleAscend;
                    } else {
                      _selectedSortingOption.removeAscend;
                      _selectedSortingOption = newOption;
                      _selectedSortingOption.toggleAscend;
                    }
                  });
                },
                value: _selectedSortingOption,
              )
            ],
          )
        ],
      ),
    );
  }
}

enum SortingValues { name, distance, waterQuality, municipalityName }

class SortingOption {
  SortingValues value;
  bool? isAscending;

  SortingOption({required this.value, required this.isAscending});

  List<Beach> sortBeach(
      List<Beach> beaches, SortingOption option, LatLng? userPosition) {
    List<Beach> beachesToReturn = beaches;
    switch (option.value) {
      case SortingValues.name:
        beachesToReturn = beaches..sort((a, b) => a.name.compareTo(b.name));
      case SortingValues.distance:
        if (userPosition == null) return beaches;
        beachesToReturn = beaches
          ..sort((a, b) => a
              .distanceInKm(userPosition)!
              .compareTo(b.distanceInKm(userPosition)!));
      case SortingValues.waterQuality:
      // TODO: make this sort from bad to good and vise versa;
      case SortingValues.municipalityName:
        beachesToReturn = beaches
          ..sort((a, b) => a.municipality.compareTo(b.municipality));
    }
    if (isAscending == false) {
      beachesToReturn = beachesToReturn.reversed.toList();
    }
    return beachesToReturn;
  }

  get removeAscend {
    isAscending = null;
  }

  get toggleAscend {
    if (isAscending == null) {
      isAscending = true;
      return;
    }
    isAscending = !isAscending!;
  }
}
