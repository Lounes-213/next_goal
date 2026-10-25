import 'package:flutter/material.dart';

/// Represents the app colors entity/model.
class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0D1B2A);

  // Gold / Dahabi
  static const Color gold = Color(0xFFD4A843);
  static const Color goldLight = Color(0xFFE8C96A);
  static const Color goldDark = Color(0xFFB8922E);

  // Dark Mode - Deep Blue
  static const Color darkSurface = Color(0xFF132238);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkScaffold = Color(0xFF0A1628);

  static const Color red = Color(0xFFE11D48);
  static const Color lightRed = Color(0xFFFB7185);

  static const Color blueGrey = Color(0xFF64748B);

  static const Color green = Color(0xFFD4A843);
  static const Color darkGreen = Color(0xFFB8922E);

  static const Color yellow = Color(0xFFF59E0B);

  static const Color blue = Color(0xFF3B82F6);
  static const Color darkBlue = Color(0xFF1D4ED8);

  static const Color deepOrange = Color(0xFFF97316);

  static const Color grey = Color(0xFF94A3B8);
  static const Color darkGrey = Color(0xFF475569);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color lightGrey = Color(0xFFF1F5F9);

  // Light Mode Surfaces
  static const Color lightScaffold = Color(0xFFECF0F3);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightOnSurface = Color(0xFF1E293B);

  // Surface & Glass Colors
  static const Color lightSurfaceGlass = Color(0xCCFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color darkSurfaceGlass = Color(0x80132238);
  static const Color darkSurfaceElevated = Color(0xFF1A2D45);

  // Text & Dividers
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightTextSubtle = Color(0xFF94A3B8);
  static const Color lightDividerSubtle = Color(0xFFE2E8F0);

  static const Color darkTextMuted = Color(0xFF8899AA);
  static const Color darkTextSubtle = Color(0xFF5A6B7D);
  static const Color darkDividerSubtle = Color(0xFF1E3350);

  // Status
  static const Color onLive = red;
  static const Color onScheduled = gold;
  static const Color onEnded = grey;

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[goldLight, gold],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[blue, darkBlue],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightRed, red],
  );

  static const LinearGradient liveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[lightRed, red],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[goldLight, gold],
  );
}
