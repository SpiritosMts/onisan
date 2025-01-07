import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
enum AppFont {
  JosefinSans,
  Roboto,
  Lato,
  // Add more fonts as needed
}

class Fm {
  static AppFont _currentFont = AppFont.JosefinSans;

  // Method to switch fonts
  static void switchFont(AppFont font) {
    _currentFont = font;
  }

  // Getters to access text theme based on the current font
  static TextTheme get textTheme {
    switch (_currentFont) {
      case AppFont.Roboto:
        return GoogleFonts.robotoTextTheme();
      case AppFont.Lato:
        return GoogleFonts.latoTextTheme();
      case AppFont.JosefinSans:
      default:
        return GoogleFonts.josefinSansTextTheme();
    }
  }
}
