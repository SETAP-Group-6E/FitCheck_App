import 'dart:ui';
import 'package:fitcheck/Presentation/app_style/backlight_gradient.dart';
import 'package:flutter/material.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
	return Scaffold(
		body: BacklightGradient(
			colorBg: const Color.fromRGBO(59, 44, 32, 1),

    light1: const [
      Color.fromRGBO(255, 255, 255, 1),
      Color.fromRGBO(59, 44, 32, 1),
      Color.fromRGBO(91, 91, 91, 0.3),
    ],

    light1Alignment: const Alignment(0.8, -0.8),
    light1Radius: 2,

    light2: const [
      Color.fromRGBO(192, 192, 192, 0.2),
      Color.fromRGBO(59, 44, 32, 0.3),
      Color.fromRGBO(59, 44, 32, 1),
    ],

    light2Alignment: const Alignment(-1, 1),
    light2Radius: 1.5,

    blur: 90,

    child: Text('Wardrobe Page'),
  ),
);
  }
}

