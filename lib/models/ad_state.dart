import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid
        ? "ca-app-pub-8900682136143703/6298606349"
        : "ca-app-pub-8900682136143703/3060153193";
  }

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
