import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onisan/onisan.dart';

class AnimatedSnackBar {
  static final AnimatedSnackBar _instance = AnimatedSnackBar._internal();
  factory AnimatedSnackBar() => _instance;
  AnimatedSnackBar._internal();

  OverlayEntry? _overlayEntry;
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;
  bool _isShowing = false;

  void show({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    Duration animationDuration = const Duration(milliseconds: 600),
  }) {
    if (_isShowing) return;

    final context = NavigatorService.navigatorKey!.currentState?.overlay?.context;
    if (context == null) {
      print("## Error: No valid context found to display the snackbar.");
      return;
    }

    _isShowing = true;

    _controller = AnimationController(
      duration: animationDuration,
      vsync: NavigatorService.navigatorKey!.currentState!,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0), // Start from off-screen at the top
      end: const Offset(0.0, 0.0),    // End at the top of the screen
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.linearToEaseOut,
    ));

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.top + 50.0,
        left: 20.0,
        right: 20.0,
        child: SlideTransition(
          position: _offsetAnimation!,
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller == null || _overlayEntry == null || NavigatorService.navigatorKey!.currentState?.overlay == null) {
        _isShowing = false;
        return;
      }

      NavigatorService.navigatorKey!.currentState!.overlay!.insert(_overlayEntry!);
      _controller!.forward();
    });

    Future.delayed(duration, () async {
      if (_controller == null || _overlayEntry == null) return;

      try {
        await _controller!.reverse();
      } catch (error) {
        // Handle any error during the animation reversal
        print("## Error during animation reverse: $error");
      } finally {
        // Check if _overlayEntry is still valid before removing it
        if (_overlayEntry != null && _overlayEntry!.mounted) {
          _overlayEntry!.remove();
        }
        _controller?.dispose();
        _controller = null;
        _overlayEntry = null; // Ensure the overlay entry is nullified
        _isShowing = false;
      }
    });
  }

}

animatedSnack({
  String message = 'Your selections have been updated',
  String type ='err',// 'succ' ; 'hint'
  int duration = 2,
}) {
  String title ='Error!';
  Color col =Cm.errorCol;
  Icon ic = Icon(Icons.error, color: Cm.errorCol);
  switch (type) {
    case 'err':
      title ='Error!';
      col =Cm.errorCol;
      ic = Icon(Icons.error, color: Cm.errorCol);

    case 'succ':
      title = 'Success!' ;
      col = Cm.succCol;
      ic = Icon(Icons.check_circle, color: Cm.succCol);


    case 'hint':
      title = 'Hint' ;
      col = Cm.greyCol;
      ic = Icon(Icons.info, color: Cm.greyCol);


  }


  AnimatedSnackBar().show(
    duration :  Duration(seconds: duration),
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Cm.bgCol2,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color:col, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ic,
          SizedBox(width: 8),
          Expanded( // Allows the text to wrap within the available space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: TextStyle(
                    color: Cm.textCol2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  message.tr,
                  style: TextStyle(color: Cm.textCol2),
                  softWrap: true,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis, // Add ellipsis if text exceeds 3 lines
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}