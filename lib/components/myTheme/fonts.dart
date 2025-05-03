import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onisan/components/myTheme/themeManager.dart';

enum AppFont {
  Almarai,
  JosefinSans,
  Roboto,
  Lato,
}

class Fm {
  static AppFont _currentFont = AppFont.Almarai; // Default to Almarai

  // Method to switch fonts
  static void switchFont(AppFont font) {
    _currentFont = font;
  }

  // Getters to access text theme based on the current font
  static TextTheme get textTheme {
    TextTheme baseTheme;
    switch (_currentFont) {
      case AppFont.Roboto:
        baseTheme = GoogleFonts.robotoTextTheme();
        break;
      case AppFont.Lato:
        baseTheme = GoogleFonts.latoTextTheme();
        break;
      case AppFont.JosefinSans:
        baseTheme = GoogleFonts.josefinSansTextTheme();
        break;
      case AppFont.Almarai:
      default:
        baseTheme = GoogleFonts.almaraiTextTheme();
    }
    // Apply bodyColor and displayColor
    return baseTheme.apply(
      bodyColor: Cm.textCol,
      displayColor: Cm.textCol,
    );
  }
}
