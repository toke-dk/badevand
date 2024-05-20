import 'dart:math';

import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WindDirection {
  double angle;

  WindDirection({required this.angle});

  Widget get getChildWidget {
    print(angle);
    print((angle % 360 + 180)*(pi/180));
    return Transform.rotate(
      angle: (angle % 360 + 180).toRadiansFromDegree,
      child: const Icon(Icons.arrow_upward),
    );
  }
}
