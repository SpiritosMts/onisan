
//textFields
import 'package:flutter/material.dart';
import 'package:get/get.dart';

fieldFocusChange(FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(Get.context!).requestFocus(nextFocus);
}
fieldUnfocusAll() {
  FocusManager.instance.primaryFocus?.unfocus();
}


void hideKeyboard() {
  FocusScope.of(Get.context!).requestFocus(FocusNode());
}