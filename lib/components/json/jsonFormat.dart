

//json
import 'dart:convert';

import 'package:flutter/material.dart';

printJson(json) {
  final encoder = JsonEncoder.withIndent('  '); // Set the indentation to 2 spaces
  final prettyPrintedJson = encoder.convert(json);
  print("## ##");
  debugPrint(prettyPrintedJson);
  print("## ##");
}