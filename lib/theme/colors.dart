import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF0E1015);
  static const surface = Color(0xFF141923);
  static const surfaceLowest = Color(0xFF0B0E14);
  static const surfaceLow = Color(0xFF151B26);
  static const surfaceMid = Color(0xFF1B2230);
  static const surfaceHigh = Color(0xFF222B3B);
  static const surfaceHighest = Color(0xFF2A3547);
  static const surfaceBright = Color(0xFF323E54);

  static const primary = Color(0xFF79F2D7);
  static const onPrimary = Color(0xFF0B1614);
  static const primaryContainer = Color(0xFF1C3A36);

  static const onSurface = Color(0xFFE8EDF6);
  static const onSurfaceVar = Color(0xFFB6C0CF);
  static const outline = Color(0xFF5A667B);
  static const outlineVar = Color(0xFF2B3343);

  static const error = Color(0xFFFF6B6B);
  static const onError = Color(0xFF3B0A0A);
  static const errorContainer = Color(0xFF5A0E14);
  static const onErrorContainer = Color(0xFFFFD6D6);

  static const green = Color(0xFF54E39A);
  static const greenDim = Color(0x1A54E39A);
  static const amber = Color(0xFFFFB74D);
  static const info = Color(0xFF6AD7FF);
}

const kHeadline = TextStyle(fontFamily: 'SpaceGrotesk');
const kBody = TextStyle(fontFamily: 'Inter');

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(
      surface: C.surface,
      onSurface: C.onSurface,
      primary: C.primary,
      onPrimary: C.onPrimary,
      error: C.error,
      onError: C.onError,
      errorContainer: C.errorContainer,
      onErrorContainer: C.onErrorContainer,
      outline: C.outline,
      outlineVariant: C.outlineVar,
    ),
  );

  final textTheme = base.textTheme.copyWith(
    displayLarge: kHeadline.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      color: C.onSurface,
      letterSpacing: -0.6,
    ),
    displayMedium: kHeadline.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: C.onSurface,
      letterSpacing: -0.4,
    ),
    titleLarge: kHeadline.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: C.onSurface,
    ),
    titleMedium: kHeadline.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: C.onSurface,
    ),
    bodyLarge: kBody.copyWith(
      fontSize: 16,
      color: C.onSurface,
      height: 1.5,
    ),
    bodyMedium: kBody.copyWith(
      fontSize: 14,
      color: C.onSurfaceVar,
      height: 1.5,
    ),
    labelLarge: kBody.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: C.onSurface,
    ),
    labelMedium: kBody.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.2,
      color: C.onSurfaceVar,
    ),
  );

  final textThemeApplied = textTheme.apply(fontFamily: 'Inter');

  return base.copyWith(
    textTheme: textThemeApplied,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: C.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: const IconThemeData(color: C.onSurface),
    dividerTheme: const DividerThemeData(color: C.outlineVar, thickness: 1),
    // Custom card styling omitted to avoid SDK mismatches; use surface colors in widgets.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.surfaceLow,
      hintStyle: const TextStyle(color: C.outline),
      labelStyle: const TextStyle(color: C.onSurfaceVar),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.surfaceHigh,
      contentTextStyle: const TextStyle(color: C.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: C.primary,
        textStyle: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.primary,
        foregroundColor: C.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        textStyle: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 1.6,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.onSurface,
        side: const BorderSide(color: C.outlineVar),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        textStyle: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
