import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvg extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Widget? placeholder;

  const CustomSvg({
    Key? key,
    required this.url,
    required this.width,
    required this.height,
    this.fadeInDuration = const Duration(milliseconds: 0),
    this.fadeOutDuration = const Duration(milliseconds: 200),
    this.placeholder,
  }) : super(key: key);

  @override
  _CustomSvgState createState() => _CustomSvgState();
}

class _CustomSvgState extends State<CustomSvg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );

    // Define fade-in animation
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the fade-in animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SvgPicture.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,

        placeholderBuilder: (context) => widget.placeholder ??
            Center(
              child: CircularProgressIndicator(),
            ),
      ),
    );
  }
}
