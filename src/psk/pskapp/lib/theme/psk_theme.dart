import 'package:flutter/material.dart';
import 'psk_colors.dart';

class PskTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: PskColors.brandBlue,
      scaffoldBackgroundColor: PskColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: PskColors.brandBlue,
        secondary: PskColors.accentGold,
        surface: PskColors.surfaceDark,
        error: PskColors.alertRed,
        onPrimary: PskColors.textWhite,
        onSecondary: PskColors.textDark,
        onSurface: PskColors.textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PskColors.bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: PskColors.textWhite),
        titleTextStyle: TextStyle(
          color: PskColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PskColors.bgDarkSecondary,
        selectedItemColor: PskColors.brandBlueLight,
        unselectedItemColor: PskColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
      ),
      cardTheme: CardThemeData(
        color: PskColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: PskColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      dividerTheme: const DividerThemeData(
        color: PskColors.borderDark,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PskColors.surfaceDarkAction,
        selectedColor: PskColors.brandBlue,
        labelStyle: const TextStyle(color: PskColors.textWhite, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: PskColors.brandBlue,
      scaffoldBackgroundColor: PskColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: PskColors.brandBlue,
        secondary: PskColors.accentGold,
        surface: PskColors.surfaceLight,
        error: PskColors.alertRed,
        onPrimary: PskColors.textWhite,
        onSecondary: PskColors.textDark,
        onSurface: PskColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PskColors.brandBlue,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: PskColors.textWhite),
        titleTextStyle: TextStyle(
          color: PskColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PskColors.surfaceLight,
        selectedItemColor: PskColors.brandBlue,
        unselectedItemColor: PskColors.textDarkSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
      ),
      cardTheme: CardThemeData(
        color: PskColors.surfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: PskColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      dividerTheme: const DividerThemeData(
        color: PskColors.borderLight,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PskColors.surfaceLightAction,
        selectedColor: PskColors.brandBlue,
        labelStyle: const TextStyle(color: PskColors.textDark, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}
