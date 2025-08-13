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
  static Color get bgCol => _currentPalette.bgCol;// background color (scaffold...)
  static Color get bgCol2 => _currentPalette.bgCol2;// background color 2 (card,dialog,container,appbar...)
  static Color get textCol => _currentPalette.textCol;// text color (main) use generally on bgCol containers or scaffold or buttons
  static Color get textCol2 => _currentPalette.textCol2;// text color 2 (secondary) use generally on bgCol2
  static Color get shadowCol => _currentPalette.shadowCol;// shadow color (used in cards
  static Color get textColPr => _currentPalette.textColPr;//text color primary use generally on primaryColor
  static Color get textColSe => _currentPalette.textColSe;// text color secondary use generally on secondaryColor
  static Color get textHintCol => _currentPalette.textHintCol;//text hint color (input fields) and used for min opacity
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

Color darkenColor(Color color, [double amount = 0.3]) {
  return Color.lerp(color, Colors.black, amount) ?? color;
}

//all

