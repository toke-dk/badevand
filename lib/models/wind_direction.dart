import 'dart:math';

import 'package:badevand/extenstions/numbers_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WindDirection {
  double angle;

  WindDirection({required this.angle});

  Widget get getChildWidget => Transform.rotate(
        angle: angle.toRadiansFromDegree,
        child: const Icon(Icons.arrow_downward),
      );
}
