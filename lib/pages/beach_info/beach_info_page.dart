import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/pages/beach_info/specs_widget.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../models/beach.dart';

class BeachInfoPage extends StatefulWidget {
  const BeachInfoPage({super.key});

  @override
  State<BeachInfoPage> createState() => _BeachInfoPageState();
}

class _BeachInfoPageState extends State<BeachInfoPage> {
  int? maxLines = 3;

  Beach get _beach => context.read<BeachesProvider>().getCurrentlySelectedBeach;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _beach.description == "" || _beach.description == null
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        maxLines = maxLines != null ? null : 3;
                      });
                    },
                    child: Text(
                      _beach.description!,
                      style: textTheme.bodySmall!
                          .copyWith(color: Colors.grey[700]),
                      maxLines: maxLines,
                      overflow: maxLines == null ? null : TextOverflow.ellipsis,
                    )),
            _beach.comments == "" || _beach.comments == null
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        maxLines = maxLines != null ? null : 3;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(
                        _beach.comments!,
                        style: textTheme.bodySmall!
                            .copyWith(color: Colors.grey[700]),
                        maxLines: maxLines,
                        overflow:
                            maxLines == null ? null : TextOverflow.ellipsis,
                      ),
                    )),
            SpecsWidget(),
          ],
        ),
      ),
    );
  }
}
