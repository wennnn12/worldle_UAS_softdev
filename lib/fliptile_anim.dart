import 'package:flutter/material.dart';
import 'dart:math';

class FlipTile extends StatefulWidget {
  final String letter;
  final Color color;
  final int delay;
  final GlobalKey<FlipTileState> key;
  final bool isDarkMode;

  const FlipTile({
    required this.letter,
    required this.color,
    required this.delay,
    required this.key,
    required this.isDarkMode,  
  }) : super(key: key);

  @override
  FlipTileState createState() => FlipTileState();
}

class FlipTileState extends State<FlipTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (!_isFlipped) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        _controller.forward().then((_) {
          setState(() {
            _isFlipped = true;
          });
        });
      });
    }
  }

  void reset() {
    setState(() {
      _isFlipped = false;
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        final isFront = angle < pi / 2 || angle > 3 * pi / 2;

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isFront
              ? Container(
                  decoration: BoxDecoration(
                    color: widget.isDarkMode
                        ? const Color.fromARGB(255, 50, 50, 50)
                        : const Color.fromARGB(255, 250, 250, 250),
                    border: Border.all(
                      color: widget.isDarkMode  
                          ? Color.fromARGB(255, 50, 50, 50)
                          : Color.fromARGB(255, 210, 214, 219),  
                      width: 2,  
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      widget.letter,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 30,
                        fontFamily: 'FranklinGothic-Bold',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.color,  
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        widget.letter,
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 30,
                          fontFamily: 'FranklinGothic-Bold',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
