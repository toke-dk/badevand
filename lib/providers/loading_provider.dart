import 'package:flutter/cupertino.dart';

class LoadingProvider extends ChangeNotifier {
  bool _isAppLoading = false;
  bool get getIsAppLoading => _isAppLoading;
  void toggleAppLoadingState(bool newState) {
    _isAppLoading = newState;
    notifyListeners();
  }
}