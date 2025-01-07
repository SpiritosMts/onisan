


import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlackSnackbar {
  static snackbar(
      String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }
}
