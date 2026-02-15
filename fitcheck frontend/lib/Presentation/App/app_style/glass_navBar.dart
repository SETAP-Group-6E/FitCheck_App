import 'package:flutter/material.dart';
import 'glass_frame.dart';

class GlassNavBar extends StatelessWidget {
  final List<Widget> items;
  final double width;
  final double height;
  final double bottomPadding;
  final BorderRadius borderRadius;

  const GlassNavBar({
    super.key,
    required this.items,
    this.width = 470,
    this.height = 60,
    this.bottomPadding = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding,
      child: Center(
        child: GlassFrame(
          borderRadius: borderRadius,
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.2),
            width: width,
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items,
            ),
          ),
        ),
      ),
    );
  }
}