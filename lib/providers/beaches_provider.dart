import 'package:flutter/cupertino.dart';

import '../models/beach.dart';

class BeachesProvider extends ChangeNotifier {
  List<Beach> _beaches = [];

  List<Beach> get getBeaches => _beaches;

  set setBeaches(List<Beach> newBeaches) {
    _beaches = newBeaches;
    notifyListeners();
  }

  set changeValueFavoriteBeach(Beach beachChange) {
    if (!_beaches.contains(beachChange)) return;

    final int index = _beaches.indexOf(beachChange);
    _beaches[index].isFavourite = !_beaches[index].isFavourite;
    notifyListeners();
  }
}