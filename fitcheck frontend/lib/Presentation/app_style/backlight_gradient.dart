import 'dart:ui';

import 'package:flutter/material.dart';

class BacklightGradient extends StatelessWidget {
  final Widget child;

  final Color colorBg;

  // light 1
  final List<Color> light1;
  final Alignment light1Alignment;
  final double light1Radius;

  // light 2
  final List<Color> light2;
  final Alignment light2Alignment;
  final double light2Radius;

  
  final double blur;

 