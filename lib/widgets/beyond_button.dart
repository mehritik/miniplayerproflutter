import 'dart:math';
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

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
    _showFireEffect(details.globalPosition);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  void _showFireEffect(Offset position) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: FireSparkles(position: position),
          ),
        );
      },
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 600), () {
      overlayEntry.remove();
    });
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
              colors: [Color(0xFF3A3A3A), Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              // Deep bottom shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                offset: const Offset(0, 8),
                blurRadius: 15,
              ),
              // Highlight at the top for glossy effect
              const BoxShadow(
                color: Color(0x33FFFFFF),
                offset: Offset(0, -3),
                blurRadius: 6,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Gloss overlay for 3D look
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
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
            ],
          ),
        ),
      ),
    );
  }
}

/// Fire sparkles painter
class FireSparkles extends StatefulWidget {
  final Offset position;
  const FireSparkles({super.key, required this.position});

  @override
  State<FireSparkles> createState() => _FireSparklesState();
}

class _FireSparklesState extends State<FireSparkles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rand = Random();

    _particles = List.generate(20, (i) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 40 + rand.nextDouble() * 60;
      final color = [
        Colors.orange,
        Colors.deepOrange,
        Colors.yellow,
        Colors.red
      ][rand.nextInt(4)];
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        radius: 2 + rand.nextDouble() * 3,
        color: color,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _FirePainter(
            particles: _particles,
            progress: _controller.value,
            origin: widget.position,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double dx, dy, radius;
  final Color color;
  _Particle({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
  });
}

class _FirePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Offset origin;

  _FirePainter({
    required this.particles,
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;
      final dx = origin.dx + p.dx * progress;
      final dy = origin.dy + p.dy * progress;
      final radius = p.radius * (1 - progress);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
