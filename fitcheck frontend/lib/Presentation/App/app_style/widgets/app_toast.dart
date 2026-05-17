import 'package:flutter/material.dart';

// App toast helper: lightweight overlay message used instead of
// `SnackBar` for a cleaner, less intrusive notification UX. Animates
// fade in/out, supports short durations and an error state.
void showAppMessage(
  BuildContext context,
  String message, {
  bool error = false,
  Duration duration = const Duration(seconds: 1),
}) {
  final overlay = Overlay.of(context);
  // Local visibility flag used by the StatefulBuilder to trigger
  // AnimatedOpacity transitions when the overlay shows/hides.
  bool visible = false;

  final entry = OverlayEntry(
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      return Positioned(
        left: 24,
        right: 24,
        bottom: mq.viewInsets.bottom + 24,
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (c, setState) {
              // AnimatedOpacity provides the fade-in/out animation.
              return AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // Error messages use a red accent, otherwise a dark
                    // translucent background for better contrast.
                    color: error ? Colors.redAccent.shade200 : Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    child: Text(message),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );

  // Insert overlay entry and schedule show/hide lifecycle. We delay the
  // initial show slightly so rapid sequences of UI changes feel smoother.
  overlay.insert(entry);

  const showDelay = Duration(milliseconds: 300);
  Future.delayed(showDelay, () {
    // Mark visible to start the fade-in animation
    visible = true;
    entry.markNeedsBuild();

    // After the requested visible duration, fade out then remove the
    // overlay entry completely.
    Future.delayed(duration, () {
      visible = false;
      entry.markNeedsBuild();
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          entry.remove();
        } catch (_) {}
      });
    });
  });
}
