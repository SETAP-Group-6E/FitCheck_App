// DashedBox: small utility widget that paints a dashed rectangle border.
// Sourced and adapted from community samples. Useful for 'upload' tiles
// and other highlight areas where a dashed outline is desired.
// License: CC BY-SA (source attribution retained).
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashedBox extends StatelessWidget {
  // Color used to draw the dashed stroke.
  final Color color;

  // Width of each painted dash stroke.
  final double strokeWidth;

  // Gap between dash segments in logical pixels.
  final double gap;

  /// Creates a lightweight dashed rectangle painter that can be used as
  /// a border for upload areas or highlighted containers. The widget
  /// simply delegates painting to [DashBoxPainter] and adds a small
  /// padding equal to half the stroke width so the stroke is fully
  /// visible inside its bounds.
  const DashedBox({
    super.key,
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // pad half the stroke so the border is not clipped at the edges
      padding: EdgeInsets.all(strokeWidth / 2),
      child: CustomPaint(
        painter: DashBoxPainter(
          color: color,
          strokeWidth: strokeWidth,
          gap: gap,
        ),
      ),
    );
  }
}

class DashBoxPainter extends CustomPainter {
  // Stroke width for the dashed lines
  double strokeWidth;

  // Color for the dashes
  Color color;

  // Distance between dash segments
  double gap;

  /// The painter draws four dashed edges by computing a dashed path for
  /// each side and stroking it. The algorithm computes points along the
  /// requested edge separated by `gap`, alternating between moveTo and
  /// lineTo to create dashes.
  DashBoxPainter({
    this.strokeWidth = 5.0,
    this.color = Colors.red,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Configure paint for stroke-only drawing.
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double x = size.width;
    final double y = size.height;

    // Build dashed paths for each side of the rectangle. We compute a
    // slightly offset left path using a tiny x value to avoid a zero-
    // length horizontal vector when computing angles.
    Path topPath = getDashedPath(
      a: math.Point(0, 0),
      b: math.Point(x, 0),
      gap: gap,
    );

    Path rightPath = getDashedPath(
      a: math.Point(x, 0),
      b: math.Point(x, y),
      gap: gap,
    );

    Path bottomPath = getDashedPath(
      a: math.Point(0, y),
      b: math.Point(x, y),
      gap: gap,
    );

    Path leftPath = getDashedPath(
      a: math.Point(0, 0),
      // small non-zero x to compute an angle for the vertical side
      b: math.Point(0.001, y),
      gap: gap,
    );

    // Draw each dashed edge.
    canvas.drawPath(topPath, dashedPaint);
    canvas.drawPath(rightPath, dashedPaint);
    canvas.drawPath(bottomPath, dashedPaint);
    canvas.drawPath(leftPath, dashedPaint);
  }

  /// Compute a dashed path between points `a` and `b`.
  ///
  /// The function walks from `a` to `b` in steps of length `gap`. It
  /// alternates between adding a line segment and moving the current
  /// point to create the visible dash / gap pattern.
  Path getDashedPath({
    required math.Point<double> a,
    required math.Point<double> b,
    required gap,
  }) {
    final Size size = Size(b.x - a.x, b.y - a.y);
    final Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    math.Point currentPoint = math.Point(a.x, a.y);

    // Angle of the segment. Handles horizontal and vertical edges by
    // computing atan(deltaY / deltaX). Caller uses a tiny non-zero
    // delta when necessary to avoid divide-by-zero.
    final num radians = math.atan(size.height / size.width);

    // Compute dx/dy steps based on the requested gap.
    final num dx = math.cos(radians) * gap < 0
        ? math.cos(radians) * gap * -1
        : math.cos(radians) * gap;

    final num dy = math.sin(radians) * gap < 0
        ? math.sin(radians) * gap * -1
        : math.sin(radians) * gap;

    // Walk along the edge until the end point is reached or exceeded.
    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      if (shouldDraw) {
        path.lineTo(currentPoint.x as double, currentPoint.y as double);
      } else {
        path.moveTo(currentPoint.x as double, currentPoint.y as double);
      }
      shouldDraw = !shouldDraw;
      currentPoint = math.Point(
        currentPoint.x + dx,
        currentPoint.y + dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // This painter is cheap; repaint when anything changes.
    return true;
  }
}
