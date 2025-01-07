import 'package:flutter/material.dart';
import 'package:onisan/onisan.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerPlaceholder(size) {
  return Shimmer.fromColors(
//    baseColor: Colors.grey[300]!, // Base shimmer color (light grey)

    baseColor: Colors.transparent, // Transparent background
    highlightColor: Cm.revOpacity2.withOpacity(0.3), // Moving red shimmer
    //highlightColor: Cm.revOpacity.withOpacity(0.3), // Moving red shimmer
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Cm.bgCol, // Transparent background
        borderRadius: BorderRadius.circular(50.0),
        //border: Border.all(color: Colors.red.withOpacity(0.5)), // Optional border
      ),
    ),
  );
}