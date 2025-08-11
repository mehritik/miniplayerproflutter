import 'dart:ui';
import 'package:flutter/material.dart';

class BeyondButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const BeyondButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<BeyondButton> createState() => _BeyondButtonState();
}

class _BeyondButtonState extends State<BeyondButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    super.initState();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    setState(() => _scale = 0.96);
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    setState(() => _scale = 1.0);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _scale = 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: disabled ? null : _onTapDown,
      onTapUp: disabled ? null : _onTapUp,
      onTapCancel: disabled ? null : _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Glass blur background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      // Outer glow in brand coral-red
                      BoxShadow(
                        color: const Color(0xFFFF4D4D).withOpacity(0.7),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                      // Depth shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        fontSize: 17,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
