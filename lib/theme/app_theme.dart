import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color backgroundTop = Color(0xFF14122B);
  static const Color backgroundBottom = Color(0xFF231934);
  static const Color surface = Color(0xFF211D3B);
  static const Color emptyCell = Color(0xFF2E2A4E);
  static const Color accent = Color(0xFF22D3EE);
  static const Color accentWarm = Color(0xFFFB7CB4);
  static const Color textPrimary = Color(0xFFF4F2FF);
  static const Color textMuted = Color(0xFFA79FD1);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  static const LinearGradient titleGradient = LinearGradient(
    colors: [accent, accentWarm],
  );

  static Color tileColor(int value) {
    final exponent = (value.bitLength - 1).clamp(1, 20);
    final hue = (195 + (exponent - 1) * 27) % 360;
    final lightness = exponent <= 2 ? 0.72 : 0.58;
    return HSLColor.fromAHSL(1, hue.toDouble(), 0.72, lightness).toColor();
  }
}
