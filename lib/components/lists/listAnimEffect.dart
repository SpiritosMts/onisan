import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimationEffects {
  // Fade and Slide from Bottom
  static List<Effect> fadeSlideFromBottom({Duration duration = const Duration(milliseconds: 300)}) {
    return [
      FadeEffect(duration: duration),
      SlideEffect(
        begin: Offset(0, 0.2), // Slide from bottom
        end: Offset.zero,
        duration: duration,
      ),
    ];
  }

  // Scale Effect
  static List<Effect> scaleEffect({
    Offset begin = const Offset(0.5, 0.5), // Scale to 50% of the original size
    Offset end = const Offset(1.0, 1.0),   // Scale to 100% (original size)
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    return [
      ScaleEffect(
        begin: begin,
        end: end,
        duration: duration,
        curve: curve,
      ),
    ];
  }

  // Scale and Rotate
  static List<Effect> scaleRotate({Duration duration = const Duration(milliseconds: 400)}) {
    return [
      ...scaleEffect(duration: duration),
      RotateEffect(
        begin: -0.05,
        end: 0.0,
        duration: duration,
        curve: Curves.easeInOut,
      ),
    ];
  }

  // Bounce
  static List<Effect> bounce({Duration duration = const Duration(milliseconds: 500)}) {
    return [
      ScaleEffect(
        begin: Offset(0.9, 0.9), // Scale slightly smaller than the original size
        end: Offset(1.1, 1.1),   // Scale slightly larger than the original size
        duration: duration,
        curve: Curves.easeOut,   // Smooth transition to larger scale
      ),
      ScaleEffect(
        begin: Offset(1.1, 1.1), // Start at slightly larger size
        end: Offset(1.0, 1.0),   // Return to original size
        duration: duration,
        curve: Curves.easeIn,    // Smooth transition back to original size
      ),
    ];
  }


  // Slide from Left
  static List<Effect> slideFromLeft({Duration duration = const Duration(milliseconds: 300)}) {
    return [
      SlideEffect(
        begin: Offset(-0.2, 0),
        end: Offset.zero,
        duration: duration,
        curve: Curves.easeInOut,
      ),
    ];
  }

  // Zoom In
  static List<Effect> zoomIn({Duration duration = const Duration(milliseconds: 400)}) {
    return [
      ScaleEffect(
        begin: Offset(0.5, 0.5),
        end: Offset(1.0, 1.0),
        duration: duration,
        curve: Curves.easeOut,
      ),
    ];
  }

  // Custom Wiggle
  static List<Effect> wiggle({Duration duration = const Duration(milliseconds: 600)}) {
    return [
      RotateEffect(
        begin: -0.1,
        end: 0.1,
        duration: duration,
        curve: Curves.easeInOut,
      ),
    ];
  }
}
