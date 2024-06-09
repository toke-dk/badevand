import 'package:badevand/extenstions/beaches_extension.dart';
import 'package:badevand/extenstions/postion_extension.dart';
import 'package:badevand/models/beach.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../enums/sorting_values.dart';
import '../models/sorting_option.dart';
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

  String _selectedMunicipality = "Alle";

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
      _sortingOptions.add(SortingOption(
          value: SortingValues.distance, userPosition: userPosition!.toLatLng));
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMunicipality.toLowerCase() == "alle") {
      setState(() {
        _selectedMunicipality = _beachesMunicipalityStrings.first;
      });
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt_outlined),
              Gap(10),
              Text(
                "Filtrer og sorter",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.filter_list),
              title: Row(children: [
                const Text("Kommune"),
                const Gap(15),
                DropdownButton<String>(
                  isExpanded: false,
                  isDense: true,
                  menuMaxHeight: 350,
                  items: _beachesMunicipalityStrings
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Text(
                                  e,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ))
                      .toList(),
                  onChanged: (newVal) {
                    if (newVal == null) return;
                    setState(() {
                      _selectedMunicipality = newVal;
                    });
                  },
                  value: _selectedMunicipality,
                ),
              ])),
          ListTile(
            leading: Icon(Icons.sort),
            title: Row(
              children: [
                const Text("Sorter"),
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
                      }),
                  items: _sortingOptions
                      .map((e) => DropdownMenuItem<SortingOption>(
                            value: e,
                            child: Container(
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
                  },
                  value: _selectedSortingOption,
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: FilledButton(
                      onPressed: () {
                        context.read<BeachesProvider>().setMunicipalityFilter =
                            _selectedMunicipality;
                        context
                            .read<BeachesProvider>()
                            .sortBeaches(_selectedSortingOption);
                        Navigator.of(context).pop();
                      },
                      child: Text("Tilføj"))),
            ],
          )
        ],
      ),
    );
  }
}
