import 'package:badevand/models/beach.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

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
              Text("Kommune"),
              Gap(15),
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
          )
        ],
      ),
    );
  }
}
