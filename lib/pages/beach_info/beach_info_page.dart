import 'package:badevand/enums/water_quality.dart';
import 'package:badevand/pages/beach_info/specs_widget.dart';
import 'package:badevand/providers/beaches_provider.dart';
import 'package:badevand/providers/home_menu_index.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../models/ad_state.dart';
import '../../models/beach.dart';

class BeachInfoPage extends StatefulWidget {
  const BeachInfoPage({super.key});

  @override
  State<BeachInfoPage> createState() => _BeachInfoPageState();
}

class _BeachInfoPageState extends State<BeachInfoPage> {
  int? maxLines = 3;

  Beach get _beach => context.read<BeachesProvider>().getCurrentlySelectedBeach;

  late BeachSpecifications? specsToday = _beach.getSpecsOfToday;

  BannerAd? banner;

  @override
  void didChangeDependencies() {
    final adState = Provider.of<AdState>(context);

    adState.initialization.then((status) {
      setState(() {
        banner = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            listener: adState.bannerAdListener,
            request: AdRequest())
          ..load();
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    print('now ${DateTime.now().toUtc().toString().replaceAll(" ", "T")}');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (banner == null)
              SizedBox(
                height: 60,
              )
            else
              Container(
                height: 60,
                child: Center(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return AdWidget(
                        ad: banner!,
                      );
                    }
                  ),
                ),
              ),
            Row(
              children: [
                specsToday?.waterQualityType.flag ?? SizedBox.shrink(),
                Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _beach.name,
                        softWrap: false,
                        style: textTheme.titleMedium,
                        overflow: TextOverflow.fade,
                      ),
                      Text(_beach.municipality)
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.pin_drop_outlined),
                  onPressed: () {
                    final provider = context.read<HomeMenuIndexProvider>();
                    provider.setMapPageStartLocation(_beach.position);
                    provider.changeSelectedIndex(1);
                    Navigator.of(context).pop();
                  },
                ),
                Gap(6),
                context
                    .watch<BeachesProvider>()
                    .getCurrentlySelectedBeach
                    .createFavoriteIcon(context),
              ],
            ),
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
            SpecsWidget(beach: _beach),
          ],
        ),
      ),
    );
  }
}
