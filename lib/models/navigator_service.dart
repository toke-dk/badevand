import 'package:flutter/material.dart';

class NavigationService {
  static final instance = NavigationService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> push(Widget widget) async {
    await navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => widget));
  }
}