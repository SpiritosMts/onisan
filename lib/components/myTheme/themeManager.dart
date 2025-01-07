import 'package:flutter/material.dart';




abstract class ColorPalette {
  Color get primaryColor;
  Color get secondaryColor;
  Color get bgCol;
  Color get bgCol2;
  Color get textCol;
  Color get textCol2;
  Color get textColPr;
  Color get textColSe;
  Color get textHintCol;
  Color get textHintCol2;
  Color get textFormHintCol;
  Color get greyCol;
  Color get textFormIconCol;
  Color get riveIconCol;
  Color get shadowCol;
  Color get revOpacity;
  Color get revOpacity2;
}



class Cm {
  static late ColorPalette _currentPalette;

  // Method to switch palettes by directly passing a ColorPalette instance
  static void switchPalette(ColorPalette palette) {
    _currentPalette = palette;
  }

  // Method to get the current palette instance
  static ColorPalette getCurrentPalette() {
    return _currentPalette;
  }

  // Getter methods to retrieve colors from the current palette
  static Color get primaryColor => _currentPalette.primaryColor;
  static Color get secondaryColor => _currentPalette.secondaryColor;
  static Color get bgCol => _currentPalette.bgCol;
  static Color get bgCol2 => _currentPalette.bgCol2;
  static Color get textCol => _currentPalette.textCol;
  static Color get textCol2 => _currentPalette.textCol2;
  static Color get textColPr => _currentPalette.textColPr;
  static Color get textColSe => _currentPalette.textColSe;
  static Color get textHintCol => _currentPalette.textHintCol;
  static Color get textHintCol2 => _currentPalette.textHintCol2;
  static Color get textFormHintCol => _currentPalette.textFormHintCol;
  static Color get greyCol => _currentPalette.greyCol;
  static Color get textFormIconCol => _currentPalette.textFormIconCol;
  static Color get riveIconCol => _currentPalette.riveIconCol;
  static Color get revOpacity => _currentPalette.revOpacity;
  static Color get revOpacity2 => _currentPalette.revOpacity2;

  // **** fixed
  static Color get errorCol => Colors.red; //static
  static Color get succCol => Colors.green;//static




  static Gradient get gradItem => LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      //right
      Color.lerp(primaryColor, Colors.white, 0.4)!,

      primaryColor,
      //Color.lerp(primaryColor, Colors.white, 0.8)!,
      //secondaryColor
    ],
  );

}


Color lightenColor(Color color, [double amount = 0.3]) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}

//all

