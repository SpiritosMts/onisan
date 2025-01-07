import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';
import 'package:sizer/sizer.dart';


double btnHeight = 6.5.h;
double btnWidth = 95.w;
class CustomGradBtn extends StatefulWidget {
  final String text;
  final String disabledText;
  final bool active;
  final bool outlined;
  final double borderRadius;
  final TextStyle? textStyle;
  final TextStyle? disabledTextStyle;
  final Future<void> Function() onTapFunction; // Updated to support async
  final double width;
  final double height;

  CustomGradBtn({
    this.text = 'Next',
    this.disabledText = '',
    this.active = true,
    this.outlined = false,
    this.borderRadius = 25.0,
    this.textStyle,
    this.disabledTextStyle,
    this.onTapFunction = _defaultFunction,
    this.width = 150.0,
    this.height = 50.0,
  });

  static Future<void> _defaultFunction() async {}

  @override
  _CustomGradBtnState createState() => _CustomGradBtnState();
}

class _CustomGradBtnState extends State<CustomGradBtn> {
  bool isLoading = false;

  Future<void> _handleTap() async {
    if (isLoading) return; // Prevent multiple taps
    setState(() {
      isLoading = true;
    });

    // Execute the asynchronous function
    try {
      await widget.onTapFunction(); // Await the async function
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.active
        ? InkWell(
      splashColor: Colors.transparent, // Remove splash color
      highlightColor: Colors.transparent, // Remove highlight color
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: widget.outlined
              ? null
              : Cm.gradItem, // Gradient if not outlined
          border: widget.outlined
              ? Border.all(color: Cm.primaryColor, width: 2.0)
              : null,
        ),
        height: widget.height,
        width: widget.width,
        child: Center(
          child: isLoading
              ? SizedBox(
            width: widget.height/2.5, // Set the desired width
            height: widget.height/2.5, // Set the desired height
            child: CircularProgressIndicator(
              color: Cm.textColPr, // Loader color
            ),
          )
              : Text(
            widget.text.tr,
            style: widget.textStyle ??
                TextStyle(
                  fontSize: 15,
                  color: Cm.textColPr,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    )
        : Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color:  Cm.greyCol.withOpacity(0.5),
        border: widget.outlined
            ? Border.all(color: Cm.greyCol, width: 2.0)
            : null,
      ),
      height: widget.height,
      width: widget.width,
      child: Center(
        child: Text(
          widget.disabledText.isEmpty
              ? widget.text.tr
              : widget.disabledText.tr,
          style: widget.disabledTextStyle ??
              TextStyle(
                fontSize: 15,
                color: Cm.textColPr,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}


class OutlinedCustomBtn extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTapFunction;

  OutlinedCustomBtn({
    this.text = 'Next',
    this.active = true,
    this.onTapFunction = _defaultFunction,
  });

  static void _defaultFunction() {}

  @override
  Widget build(BuildContext context) {
    return active ? InkWell(
      splashColor: Colors.transparent, // Remove splash color
      highlightColor: Colors.transparent, // Remove highlight color

      onTap: onTapFunction,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(25),

        ),
        height: btnHeight,
        width: btnWidth,
        child: Stack(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => Cm.gradItem.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    width: 3,
                    color: Colors.white, // This color will be masked by the gradient
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Cm.bgCol2,
                borderRadius: BorderRadius.circular(22),
              ),
              margin: EdgeInsets.all(3),
              child: Center(
                child: Text(
                  text.tr,
                  style: TextStyle(
                    fontSize: 15,
                    color: Cm.textCol2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ) : Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(25),
        ),
        height: btnHeight,
        width: btnWidth ,
        child: Center(
            child: Text(
              text.tr,
              style: TextStyle(
                  fontSize: 15,
                  color: Cm.greyCol,
                  fontWeight: FontWeight.bold),
            )));
  }
}