import 'package:flutter/material.dart';

class CustomAnimatedList extends StatefulWidget {
  final ScrollController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final Duration animationDuration;

  const CustomAnimatedList({
    Key? key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _CustomAnimatedListState createState() => _CustomAnimatedListState();
}

class _CustomAnimatedListState extends State<CustomAnimatedList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<int> _items;

  @override
  void initState() {
    super.initState();
    // Initialize items with indices for animation tracking
    _items = List.generate(widget.itemCount, (index) => index);
  }

  void addItem(int index) {
    setState(() {
      _items.insert(index, index);
      _listKey.currentState?.insertItem(index, duration: widget.animationDuration);
    });
  }

  void removeItem(int index) {
    final removedIndex = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => widget.itemBuilder(context, removedIndex),
      duration: widget.animationDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      controller: widget.controller,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (widget.separatorBuilder != null && index % 2 == 1) {
          return widget.separatorBuilder!(context, index ~/ 2);
        }

        return SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}
