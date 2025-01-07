import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;

  const ErrorScreen({
    Key? key,
    this.title = "Error",
    this.message = "Something went wrong.",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cm.bgCol,

      appBar: AppBar(
        title: Text(title,style: TextStyle(color: Cm.textCol2),),
        backgroundColor: Cm.bgCol2,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Cm.textCol2),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Cm.textCol,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Cm.textHintCol,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:  Cm.primaryColor, // Custom background color
                foregroundColor: Colors.white, // Text or icon color
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Optional padding
              ),
              onPressed: () {
              },
              child: Text("Go Back".tr),///TODO
            ),
          ],
        ),
      ),
    );
  }
}