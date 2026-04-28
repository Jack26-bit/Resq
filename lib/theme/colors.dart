import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF131313);
  static const surface = Color(0xFF131313);
  static const surfaceLowest = Color(0xFF0E0E0E);
  static const surfaceLow = Color(0xFF1B1B1B);
  static const surfaceMid = Color(0xFF1F1F1F);
  static const surfaceHigh = Color(0xFF2A2A2A);
  static const surfaceHighest = Color(0xFF353535);
  static const surfaceBright = Color(0xFF393939);

  static const primary = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFF1A1C1C);
  static const primaryContainer = Color(0xFFD4D4D4);

  static const onSurface = Color(0xFFE2E2E2);
  static const onSurfaceVar = Color(0xFFC6C6C6);
  static const outline = Color(0xFF919191);
  static const outlineVar = Color(0xFF474747);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  static const green = Color(0xFF4CAF50);
  static const greenDim = Color(0x1A4CAF50);
}

const kHeadline = TextStyle(fontFamily: 'SpaceGrotesk');
const kBody = TextStyle(fontFamily: 'Inter');

ThemeData buildTheme() => ThemeData(
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
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xCC131313),
        elevation: 0,
        foregroundColor: C.primary,
      ),
    );
