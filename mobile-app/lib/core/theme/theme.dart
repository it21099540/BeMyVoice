import 'package:bemyvoice/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPalette.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.surfaceColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: AppPalette.textPrimaryColor,
      ),
    ),
  );
}
