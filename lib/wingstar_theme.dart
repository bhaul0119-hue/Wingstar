import 'package:flutter/material.dart';

class WingstarColors {
  WingstarColors._();

  // Wingstar 로고 기반 블루 계열.
  static const Color navy = Color(0xFF3B5276);
  static const Color wingBlue = Color(0xFF4F6484);
  static const Color skyBlue = Color(0xFF7992B2);
  static const Color mistBlue = Color(0xFFAEBCCE);
  static const Color cloudBlue = Color(0xFFDFE7F1);
  static const Color background = Color(0xFFF7F9FC);
  static const Color text = Color(0xFF1F2A38);
  static const Color success = Color(0xFF506C5E);
}

ThemeData buildWingstarTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: WingstarColors.wingBlue,
    brightness: Brightness.light,
    surface: Colors.white,
  ).copyWith(
    primary: WingstarColors.navy,
    secondary: WingstarColors.skyBlue,
    surface: Colors.white,
    onSurface: WingstarColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: WingstarColors.background,
    fontFamily: null,
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: WingstarColors.cloudBlue,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected)
              ? WingstarColors.navy
              : WingstarColors.wingBlue,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: WingstarColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WingstarColors.navy,
        side: const BorderSide(color: WingstarColors.mistBlue),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}
