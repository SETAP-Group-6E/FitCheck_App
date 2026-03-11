import 'package:flutter/material.dart';

class WardrobeStyles {

  static const Color card = Color(0xFF171A20);
  static const Color border = Color(0xFF2A2F38);
  static const Color gold = Color(0xFFD4A017);
  static const Color muted = Color(0xFFA1A1AA);
  static const Color inputFill = Color(0xFFE5E5E5);
  static const Color textDark = Color(0xFF111111);
  static const Color textHint = Color(0xFF6B7280);

  static BoxDecoration dialogDecoration = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration bottomBarDecoration = const BoxDecoration(
    color: card,
    border: Border(
      top: BorderSide(color: border),
    ),
  );

  static InputDecoration pillInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
    );
  }

  static InputDecoration textAreaDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      filled: true,
      fillColor: inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: gold, width: 2),
      ),
    );
  }

  static const TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelStyle = TextStyle(
    color: muted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle helperStyle = TextStyle(
    color: muted,
    fontSize: 12,
  );

  static const TextStyle textFieldStyle = TextStyle(
    color: textDark,
    fontSize: 14,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle mutedSmallStyle = TextStyle(
    color: muted,
    fontSize: 12,
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: gold,
    foregroundColor: Colors.white,
    shape: const StadiumBorder(),
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 18),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: border),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 18),
  );

  static CheckboxThemeData checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? gold
          : Colors.transparent,
    ),
    side: const BorderSide(color: border, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
    checkColor: WidgetStateProperty.all(Colors.white),
  );
}