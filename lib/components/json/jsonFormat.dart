

//json
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

printJson(dynamic json) {
  final encoder = JsonEncoder.withIndent('  ', (object) {
    if (object is GeoPoint) {
      // Custom encoding for GeoPoint
      return {
        'latitude': object.latitude,
        'longitude': object.longitude,
      };
    }
    return object; // For all other types, use the default conversion
  });

  final prettyPrintedJson = encoder.convert(json);
  print("## ##");
  debugPrint(prettyPrintedJson);
  print("## ##");
}
