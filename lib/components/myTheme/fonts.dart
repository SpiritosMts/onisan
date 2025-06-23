import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onisan/components/myTheme/themeManager.dart';

enum AppFont {
  Almarai,
  JosefinSans,
  Roboto,
  Lato,
  Barriecito,
}

class Fm {
  static AppFont _currentFont = AppFont.Barriecito; // Default to Almarai

  // Method to switch fonts
  static void switchFont(AppFont font) {
    _currentFont = font;
  }
  // Method to switch fonts
  static  TextTheme get uniqueFont {
   return GoogleFonts.robotoTextTheme();
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
        baseTheme = GoogleFonts.almaraiTextTheme();
        break;
      case AppFont.Barriecito:
        baseTheme = GoogleFonts.barriecitoTextTheme();
        break;
      default:
        baseTheme = GoogleFonts.almaraiTextTheme();
       // baseTheme = GoogleFonts.barriecitoTextTheme();
    }
    // Apply bodyColor and displayColor
    return baseTheme.apply(
      bodyColor: Cm.textCol,
      displayColor: Cm.textCol,
    );
  }
}
