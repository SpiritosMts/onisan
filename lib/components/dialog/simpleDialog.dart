import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';
import 'package:sizer/sizer.dart';

class AnimatedInfoDialog extends StatefulWidget {
  final String title;
  final String description;
  final Widget icon;
  final bool hasCancelButton;
  final VoidCallback? onOkayPressed;
  final VoidCallback? onCancelPressed;

  const AnimatedInfoDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.hasCancelButton = false,
    this.onOkayPressed,
    this.onCancelPressed,
  }) : super(key: key);

  // Static method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required Widget icon,
    bool hasCancelButton = false,
    bool barrierDismissible = true, // New parameter
    VoidCallback? onOkayPressed,
    VoidCallback? onCancelPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,

      builder: (BuildContext context) {
        return AnimatedInfoDialog(
          title: title,
          description: description,
          icon: icon,
          hasCancelButton: hasCancelButton,
          onOkayPressed: onOkayPressed,
          onCancelPressed: onCancelPressed,
        );
      },
    );
  }

  @override
  _AnimatedInfoDialogState createState() => _AnimatedInfoDialogState();
}

class _AnimatedInfoDialogState extends State<AnimatedInfoDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Circular border
          ),
          backgroundColor: Cm.bgCol2, // Use the passed parameter
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Widget
                widget.icon,

                const SizedBox(height: 16),

                // Title
                Text(
                  widget.title,
                  style:  TextStyle(
                    fontSize: 20.sp,
                    color: Cm.textCol2,

                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  widget.description,
                  style:  TextStyle(
                    fontSize: 17.sp,
                    color: Cm.textCol2,
                    fontWeight: FontWeight.w500,

                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.hasCancelButton)
                      Expanded(
                        child: TextButton(
                          onPressed: widget.onCancelPressed ?? () => Get.back(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Decreased corner radius
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (widget.hasCancelButton) const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onOkayPressed ?? () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: Cm.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Decreased corner radius
                          ),
                        ),
                        child: Text(
                          "Okay",
                          style: TextStyle(
                            color: Cm.textColPr,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}