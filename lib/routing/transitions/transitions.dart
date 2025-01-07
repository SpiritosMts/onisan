import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlideFadeTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    var fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
    var slideTween = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(animation);

    return SlideTransition(
      position: slideTween,
      child: FadeTransition(opacity: fadeTween, child: child),
    );
  }
}