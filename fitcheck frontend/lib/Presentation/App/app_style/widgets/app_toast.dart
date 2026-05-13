import 'package:flutter/material.dart';

/// Lightweight overlay message used instead of SnackBar for a cleaner look.
void showAppMessage(BuildContext context, String message, {bool error = false, Duration duration = const Duration(seconds: 1)}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;
  bool _visible = false;

  final entry = OverlayEntry(builder: (ctx) {
    final mq = MediaQuery.of(ctx);
    return Positioned(
      left: 24,
      right: 24,
      bottom: mq.viewInsets.bottom + 24,
      child: Material(
        color: Colors.transparent,
        child: StatefulBuilder(builder: (c, setState) {
          return AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: error ? Colors.redAccent.shade200 : Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                child: Text(message),
              ),
            ),
          );
        }),
      ),
    );
  });

  overlay.insert(entry);

  // wait a short time before showing the toast (gives UI a moment)
  const showDelay = Duration(milliseconds: 300);
  Future.delayed(showDelay, () {
    _visible = true;
    entry.markNeedsBuild();

    // schedule fade out and removal after the visible duration
    Future.delayed(duration, () {
      _visible = false;
      entry.markNeedsBuild();
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          entry.remove();
        } catch (_) {}
      });
    });
  });
}
