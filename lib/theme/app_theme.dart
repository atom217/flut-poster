import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color accentColor = Color(0xFFFF9800); // Orange/Saffron
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static const List<int> editorColors = [
    0xFF3F51B5, // Indigo
    0xFFF44336, // Red
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFF000000, // Black
    0xFF673AB7, // Deep Purple
  ];

  static const double minFontSize = 16.0;
  static const double maxFontSize = 40.0;
  static const double defaultFontSize = 26.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: backgroundColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
