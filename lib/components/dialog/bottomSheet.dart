import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:onisan/onisan.dart';



Future<bool> showBottomSheetDialog({
  String title = "Verification",
  String description = "Are you sure you want to perform this process?",
  String positiveButtonText = "Yes",
  VoidCallback? onPositivePressed,
  String negativeButtonText = "Cancel",
  VoidCallback? onNegativePressed,
}) async {
  Completer<bool> completer = Completer(); // Create a Completer

  showModalBottomSheet(
    context: Get.context!,
    backgroundColor: Cm.bgCol2,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Cm.textCol,
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
              child: Text(
                description.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Cm.textCol2,
                ),
              ),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Get.back();
                    if (onNegativePressed != null) {
                      onNegativePressed();
                    }
                    completer.complete(false); // Return false when Cancel is pressed
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Cm.primaryColor),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    negativeButtonText.tr,
                    style: TextStyle(
                      color: Cm.textHintCol2,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                    if (onPositivePressed != null) {
                      onPositivePressed();
                    }
                    completer.complete(true); // Return true when Yes is pressed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Cm.primaryColor, // Background color set to Cm.primaryColor
                  ),
                  child: Text(
                    positiveButtonText.tr,
                    style: TextStyle(
                      color: Cm.textColPr, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  return completer.future; // Wait for the dialog interaction
}

