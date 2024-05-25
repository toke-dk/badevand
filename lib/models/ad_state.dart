import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-3940256099942544/2934735716";

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
