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

  const BacklightGradient({
    super.key,
    required this.child,

    // Background
    this.colorBg = const Color.fromARGB(255, 44, 33, 23),

    // light 1 (center → edge)
    this.light1 = const [
      Color.fromARGB(255, 38, 38, 38), 
      Color.fromARGB(255, 76, 71, 65), 
      Color.fromARGB(0, 255, 152, 0), 
    ],
    this.light1Alignment = const Alignment(-0.5, -0.5),
    this.light1Radius = 1.2,

    // light 2
    this.light2 = const [
      Color.fromARGB(255, 0, 0, 0),
      Color.fromARGB(255, 76, 71, 65),
      Color.fromARGB(0, 255, 152, 0),
    ],
    this.light2Alignment = const Alignment(0.6, 0.4),
    this.light2Radius = 0.9,

    // Blur
    this.blur = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [

        // Base
        Container(color: colorBg),

        // light 1
        _buildBacklight(
          colors: light1,
          alignment: light1Alignment,
          radius: light1Radius,
        ),

        // light 2
        _buildBacklight(
          colors: light2,
          alignment: light2Alignment,
          radius: light2Radius,
        ),

        // Blur
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ),

        // UI
        child,
      ],
    );
  }

  Widget _buildBacklight({
    required List<Color> colors,
    required Alignment alignment,
    required double radius,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alignment,
          radius: radius,

          // Important: multi-stop gradient
          stops: const [0.0, 0.6, 1.0],

          colors: colors,
        ),
      ),
    );
  }
}