import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF536DFE);
  static const Color primaryLightColor = Color(0xFF8A9BFE);
  static const Color primaryDarkColor = Color(0xFF3D54DB);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color secondaryLightColor = Color(0xFF80E27E);
  static const Color secondaryDarkColor = Color(0xFF087F23);

  // Accent colors
  static const Color accentColor = Color(0xFFFF5722);
  static const Color accentLightColor = Color(0xFFFF8A50);
  static const Color accentDarkColor = Color(0xFFC41C00);

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFFBDBDBD);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFEEEEEE);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // App settings
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 15.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Font family
  static const String fontFamily = 'Poppins';

  // Add these to your AppTheme class
  static const TextStyle h1Style = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    fontFamily: fontFamily,
  );

  static const TextStyle h2Style = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySecondaryStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    fontFamily: fontFamily,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    fontFamily: fontFamily,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    fontFamily: fontFamily,
  );

  // Add status styles
  static const TextStyle pendingStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: warningColor,
    fontFamily: fontFamily,
  );

  static const TextStyle settledStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: successColor,
    fontFamily: fontFamily,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: errorColor,
    fontFamily: fontFamily,
  );

  // Add standard decorations
  static const BoxDecoration standardCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.all(Radius.circular(cardBorderRadius)),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
  );

  // Create the main theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textPrimaryColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textPrimaryColor),
        bodySmall: TextStyle(color: textSecondaryColor),
      ),
    );
  }
}
