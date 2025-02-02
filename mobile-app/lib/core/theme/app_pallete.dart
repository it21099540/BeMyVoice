import 'package:flutter/material.dart';

class AppPalette {
  //Primary colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFFFFFFFF);

  //Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  //Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFFFFFFFF);

  //Error, success, warning, info, disabled colors
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFE64A19);
  static const Color infoColor = Color(0xFF1976D2);
  static const Color disabledColor = Color(0xFFBDBDBD);

  //Border colors
  static const Color borderColor = Color(0xFFE0E0E0);

  //Divider color
  static const Color dividerColor = Color(0xFFBDBDBD);

  //Shadow color
  static const Color shadowColor = Color(0xFFBDBDBD);

  //Transparent color
  static const Color transparent = Color(0x00000000);

  //Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
