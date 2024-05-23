import 'package:badevand/extenstions/postion_extension.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../enums/sorting_values.dart';
import '../providers/user_position_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<Beach> get _beaches => context.watch<BeachesProvider>().getBeaches;

  List<String> get _beachesMunicipalityStrings =>
      ["Alle", ..._beaches.getBeachesMunicipalityStrings];

  String? _selectedMunicipality;

  final List<SortingOption> _sortingOptions = [
    SortingOption(value: SortingValues.name),
    SortingOption(value: SortingValues.municipalityName),
    SortingOption(value: SortingValues.waterQuality),
  ];
  late SortingOption _selectedSortingOption = _sortingOptions.first;

  Position? get userPosition =>
      context.read<UserPositionProvider>().getPosition;

  @override
  void didChangeDependencies() {
    if (userPosition != null) {
      _sortingOptions.add(SortingOption(value: SortingValues.distance));
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                  context.read<BeachesProvider>().setMunicipalityFilter = _selectedMunicipality!;
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
                icon: IconButton(
                    icon: Icon(_selectedSortingOption.isAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        _selectedSortingOption.toggleAscend;
                      });


                      context.read<BeachesProvider>().sortBeaches(
                          _selectedSortingOption, userPosition?.toLatLng);
                    }),
                items: _sortingOptions
                    .map((e) => DropdownMenuItem<SortingOption>(
                          value: e,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            // Adjust padding as needed
                            child: Text(e.value.name),
                          ),
                        ))
                    .toList(),
                onChanged: (newOption) {
                  if (newOption == null ||
                      newOption.value == _selectedSortingOption.value) return;
                  setState(() {
                    _selectedSortingOption.defaultAscend;
                    _selectedSortingOption = newOption;
                  });
                  context.read<BeachesProvider>().sortBeaches(_selectedSortingOption, userPosition?.toLatLng);
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

class SortingOption {
  SortingValues value;
  bool isAscending;

  SortingOption({required this.value, this.isAscending = true});

  get defaultAscend {
    isAscending = true;
  }

  get toggleAscend {
    isAscending = !isAscending;
  }
}
