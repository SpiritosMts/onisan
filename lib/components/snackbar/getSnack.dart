import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';

void showGetXSnackBar(String message,{
  IconData? icon = Icons.check_circle,
  Color iconColor = Colors.green,
  Color backgroundColor = Colors.white,
  Color? textColor,
  Color borderColor = Colors.green,
  Duration duration = const Duration(seconds: 4),
  bool showIcon = false,
}) {
  Get.showSnackbar(
    GetSnackBar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) Icon(icon, color: iconColor),
          if (showIcon) SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.left, // Ensures text alignment is left
              style: TextStyle(
                color: textColor ?? Colors.black,
              ),
            ),
          ),
          // IconButton(
          //   icon: Icon(Icons.close, color: iconColor),
          //   onPressed: () {
          //     Get.closeCurrentSnackbar(); // Close snackbar on close icon press
          //   },
          // ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Cm.revOpacity,
      borderRadius: 16.0,
      maxWidth: 150,
      margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 65.0), // Adds padding from the bottom
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusts inner padding

      duration: duration,
      isDismissible: true, // Allows the snackbar to be dismissed by tapping
      overlayBlur: 0, // Ensures no blur effect for the background
     // overlayColor: Cm.bgCol2, // Keep the background transparent
      // boxShadows: [
      //   BoxShadow(
      //     color: Colors.black.withOpacity(0.2), // Shadow color with opacity
      //     blurRadius: 10.0,
      //     spreadRadius: 2.0,
      //     offset: Offset(0, 4),
      //   ),
      // ],

      // mainButton: TextButton(
      //   onPressed: () => Get.closeCurrentSnackbar(),
      //   child: const Text("Close"),
      // ),
    ),
  );
}


void showSoonSnack(){
  showGetXSnackBar(
    "Soon...",
    icon: Icons.timelapse,
    iconColor: Colors.grey,
    backgroundColor: Colors.white,
    textColor: Cm.textCol,
    borderColor: Colors.grey,
    showIcon: true,
  );
}