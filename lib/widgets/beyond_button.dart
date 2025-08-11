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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _scale = 0.95);

    // Trigger particle effect
    _showParticleEffect(details.globalPosition);
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

  void _showParticleEffect(Offset position) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: CharcoalParticlesPainter(position),
            ),
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 400), () {
      overlayEntry.remove();
    });
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
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E2E2E), Color(0xFF1C1C1C)], // Charcoal gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(29), // Cylindrical
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: const Offset(0, 6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0xFF3A3A3A).withOpacity(0.6),
                offset: const Offset(0, -2),
                blurRadius: 6,
                spreadRadius: -1,
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
    );
  }
}

class CharcoalParticlesPainter extends CustomPainter {
  final Offset position;
  CharcoalParticlesPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1C1C1C).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final dx = (position.dx + (i * 6 - 30)) + (i.isEven ? -5 : 5);
      final dy = (position.dy + (i * 3 - 15)) + (i.isOdd ? -5 : 5);
      canvas.drawCircle(Offset(dx, dy), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
