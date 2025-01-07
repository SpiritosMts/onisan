import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';
import 'package:sizer/sizer.dart';

void bottomSnackBar({
  required String message,
  String type = "succ",
  int duration =  2,
  bool showBtn =true, // Custom close widget
  VoidCallback? onClosePressed, // Callback for close button
}) {

  Color iconColor = type == "succ"?Colors.green:Colors.red;
  IconData icon =type == "succ"? Icons.check_circle:Icons.remove_circle_outline;

      Color backgroundColor = Cm.bgCol2;
  Color textColor = Cm.textCol2;
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0, // Remove default elevation/shadow
      backgroundColor: Colors.transparent, // Ensure background is transparent
      margin: EdgeInsets.only(
        bottom: 0.0, // Adjust the distance from the bottom
        left: 16.0,   // Add margin on the left for alignment
        right: 16.0,  // Add margin on the right for alignment
      ),
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0), // Add vertical padding
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: iconColor, width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color with opacity
              blurRadius: 10.0, // Softness of the shadow
              spreadRadius: 2.0, // Spread radius
              offset: Offset(0, 4), // Offset in x and y direction
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
            ),
            if (showBtn)
              IconButton(
                icon: Icon(Icons.undo, color: Cm.textCol2.withOpacity(0.6)),
                onPressed: () {
                  onClosePressed?.call();
                  ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
                },
              ),
          ],
        ),
      ),
      duration: Duration(seconds: duration),
    ),
  );

}





void f() {

}