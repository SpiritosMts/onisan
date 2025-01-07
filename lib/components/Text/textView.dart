import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onisan/onisan.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;

  GradientText({
    required this.text,
    this.style,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient?.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ) ?? Cm.gradItem.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: AutoSizeText(
        text.tr,
        style: style!.copyWith(color: Colors.white),
        maxLines: 1, // Ensure it fits in one line
        //minFontSize: 12.sp, // make error
        overflow: TextOverflow.ellipsis, // Optional: Add ellipsis if the text is too long
      ),
    );
  }
}

///**************************************************
///


class ShakingText extends StatefulWidget {
  final String text;
  final bool isError;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  ShakingText({
    required this.text,
    required this.isError,
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0.1, 0.0),
    this.curve = Curves.elasticIn,
  });

  @override
  _ShakingTextState createState() => _ShakingTextState();
}
class _ShakingTextState extends State<ShakingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset,
    ).chain(CurveTween(curve: widget.curve)).animate(_controller);

    if (widget.isError) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void didUpdateWidget(ShakingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.isError ? Cm.errorCol : Cm.textHintCol,
          fontSize: 14,
        ),
      ),
    );
  }
}
///***********************************************



Widget animatedText(String txt, double textSize, int speed) {
  return SizedBox(
    height: 40,
    child: AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(txt,
            textStyle: GoogleFonts.indieFlower(
              textStyle: TextStyle(fontSize: textSize, color: Cm.textCol, fontWeight: FontWeight.w800),
            ),
            speed: Duration(
              milliseconds: speed,
            )),
      ],
      onTap: () {
        //debugPrint("Welcome back!");
      },
      isRepeatingAnimation: true,
      totalRepeatCount: 40,
    ),
  );
}