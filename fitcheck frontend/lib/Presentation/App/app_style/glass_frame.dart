import 'dart:ui';
import 'package:flutter/material.dart';

class GlassFrame extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;

  const GlassFrame({
    super.key,
    required this.child,
    this.blur = 8.0,
    this.opacity = 0.2,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 22, 22, 22).withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: const Color.fromARGB(255, 102, 102, 102).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}