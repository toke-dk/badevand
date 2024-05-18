import 'package:flutter/cupertino.dart';

import '../models/beach.dart';

class BeachesProvider extends ChangeNotifier {
  List<Beach> _beaches = [];

  List<Beach> get getBeaches => _beaches;

  void setBeaches(List<Beach> newBeaches) {
    _beaches = newBeaches;
    notifyListeners();
  }
}