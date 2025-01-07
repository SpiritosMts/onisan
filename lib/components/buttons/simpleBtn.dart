
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/components/myTheme/themeManager.dart';

class CircularButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const CircularButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Circular border
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


Widget buildNavigationButton(String title, String route) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton(
      onPressed: () => Get.toNamed(route),
      child: Text(title),
    ),
  );
}
Widget buildPressButton(String title, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Cm.bgCol2, // Match your theme
      ),
      onPressed: onPressed,
      child: Text(title),
    ),
  );
}