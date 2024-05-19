import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class UserPositionProvider extends ChangeNotifier {
  Position? _position;

  Position? get getPosition => _position;

  set setPosition(Position? position) {
    _position = position;
    notifyListeners();
  }
}