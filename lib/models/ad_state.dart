import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId => Platform.isAndroid
      ? "ca-app-pub-8900682136143703/6298606349"
      : "ca-app-pub-8900682136143703/3060153193";

  BannerAdListener get bannerAdListener => _adListener;
  BannerAdListener _adListener = BannerAdListener(
    onAdLoaded: (Ad ad) => print('Ad loaded ${ad.adUnitId}'),
    onAdFailedToLoad: (Ad ad, LoadAdError error) =>
        print('Ad failed to load: ${ad.adUnitId}, $error'),
    onAdOpened: (Ad ad) => print('Ad opened ${ad.adUnitId}'),
    onAdClosed: (Ad ad) => print('Ad closed ${ad.adUnitId}'),
    onAdClicked: (Ad ad) => print("Ad clicked ${ad.adUnitId}"),
  );
}
