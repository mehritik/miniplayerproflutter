// lib/widgets/stone_text.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// StoneText: renders [text] carved into a 3D faceted stone block.
/// - darkMode style by default to match your "47" reference (charcoal + red rim).
/// - configurable padding, rimColor, engravingDepth, and fontWeight.
class StoneText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? rimColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double engravingDepth; // higher -> deeper carving
  final bool forceDark; // if true, always use charcoal look

  const StoneText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight = FontWeight.w900,
    this.rimColor,
    this.horizontalPadding = 28.0,
    this.verticalPadding = 18.0,
    this.engravingDepth = 2.6,
    this.forceDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeIsDark = Theme.of(context).brightness == Brightness.dark;
    final bool isDark = forceDark ? true : themeIsDark;

    final double fs = fontSize ?? (isDark ? 28.0 : 28.0);

    // Measure text to size the stone block neatly
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fs,
          fontWeight: fontWeight,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 2000);

    final double textW = textPainter.width;
    final double textH = textPainter.height;

    final double width = textW + horizontalPadding * 2;
    final double height = textH + verticalPadding * 2;

    return SizedBox(
      width: width,
      height: height + 18.0, // leave room for extrusions/shadow
      child: CustomPaint(
        painter: _StoneTextPainter(
          text: text,
          fontSize: fs,
          fontWeight: fontWeight,
          rimColor: rimColor,
          isDark: isDark,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          engravingDepth: engravingDepth,
        ),
      ),
    );
  }
}

class _StoneTextPainter extends CustomPainter {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? rimColor;
  final bool isDark;
  final double horizontalPadding;
  final double verticalPadding;
  final double engravingDepth;

  _StoneTextPainter({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.rimColor,
    required this.isDark,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.engravingDepth,
  });

  // Charcoal palette similar to your reference
  final Color top = const Color(0xFF0F1112);
  final Color mid = const Color(0xFF151617);
  final Color bottom = const Color(0xFF232324);
  final Color rimDefault = const Color(0xFFB22A2A);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..isAntiAlias = true;

    // extrusions thickness
    final double extrudeX = size.height * 0.12; // proportionate to height
    final double extrudeY = size.height * 0.12;

    // front face rect (left/top anchored)
    final Rect frontRect = Rect.fromLTWH(
      0,
      0,
      size.width - extrudeX,
      size.height - extrudeY,
    );
    final double cornerRadius = (size.height * 0.12).clamp(8.0, 26.0);

    // build smooth RRect for front face
    final RRect frontRRect = RRect.fromRectAndRadius(frontRect, Radius.circular(cornerRadius));

    // Paths for right and bottom faces: connected polygons to avoid seams
    final Path rightFace = Path()
      ..moveTo(frontRect.right, extrudeY * 0.35)
      ..lineTo(frontRect.right + extrudeX, extrudeY * 0.35 + (extrudeY * 0.06))
      ..lineTo(frontRect.right + extrudeX, frontRect.bottom - (extrudeY * 0.06))
      ..lineTo(frontRect.right, frontRect.bottom)
      ..close();

    final Path bottomFace = Path()
      ..moveTo(extrudeX * 0.6, frontRect.bottom)
      ..lineTo(frontRect.right + extrudeX * 0.6, frontRect.bottom + (extrudeY * 0.02))
      ..lineTo(frontRect.right, frontRect.bottom + extrudeY)
      ..lineTo(extrudeX * 0.6, frontRect.bottom + extrudeY)
      ..close();

    // big cast shadow under the whole block
    final Path shadowPath = Path()..addRRect(frontRRect.shift(const Offset(0, 20)));
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withOpacity(0.88)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
    );

    // draw right face
    p.shader = ui.Gradient.linear(
      Offset(frontRect.right, 0),
      Offset(frontRect.right + extrudeX, frontRect.bottom),
      [mid.withOpacity(0.98), bottom.withOpacity(0.98)],
    );
    canvas.drawPath(rightFace, p);

    // draw bottom face
    p.shader = ui.Gradient.linear(
      Offset(0, frontRect.bottom),
      Offset(0, frontRect.bottom + extrudeY),
      [bottom.withOpacity(0.98), Colors.black.withOpacity(0.96)],
    );
    canvas.drawPath(bottomFace, p);

    // draw main front face
    p.shader = ui.Gradient.linear(
      frontRect.topLeft,
      frontRect.bottomRight,
      [top, mid, bottom],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRRect(frontRRect, p);

    // polished highlight on top-left
    final Rect highlight = Rect.fromLTWH(
      frontRect.left,
      frontRect.top,
      frontRect.width * 0.6,
      frontRect.height * 0.34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlight, Radius.circular(cornerRadius * 0.9)),
      Paint()
        ..shader = ui.Gradient.linear(
          highlight.topLeft,
          highlight.bottomRight,
          [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.01)],
        ),
    );

    // subtle crease for realism
    final Paint creasePaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final Path crease = Path();
    crease.moveTo(frontRect.left + frontRect.width * 0.12, frontRect.top + frontRect.height * 0.46);
    crease.quadraticBezierTo(
      frontRect.left + frontRect.width * 0.5,
      frontRect.top + frontRect.height * 0.466,
      frontRect.right - frontRect.width * 0.12,
      frontRect.top + frontRect.height * 0.48,
    );
    canvas.drawPath(crease, creasePaint);

    // rim: top thin and right thin gradient strips (adjustable)
    final Color rim = rimColor ?? rimDefault;
    final Rect topRimRect = Rect.fromLTWH(frontRect.left, frontRect.top, frontRect.width, 3);
    canvas.drawRect(
      topRimRect,
      Paint()
        ..shader = ui.Gradient.linear(
          topRimRect.topLeft,
          topRimRect.topRight,
          [rim.withOpacity(0.0), rim.withOpacity(0.95), rim.withOpacity(0.0)],
          [0.0, 0.5, 1.0],
        ),
    );
    final Rect rightRimRect = Rect.fromLTWH(frontRect.right - 2, frontRect.top, 4, frontRect.height);
    canvas.drawRect(
      rightRimRect,
      Paint()
        ..shader = ui.Gradient.linear(
          rightRimRect.topCenter,
          rightRimRect.bottomCenter,
          [rim.withOpacity(0.0), rim.withOpacity(0.95), rim.withOpacity(0.0)],
          [0.0, 0.5, 1.0],
        ),
    );

    // =========================================
    // Paint engraved text centered in frontRect
    // =========================================
    final TextSpan coreSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.95), // core color (dark)
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 1.0,
      ),
    );
    final TextSpan lightSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.14), // inner highlight
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 1.0,
      ),
    );
    final TextSpan darkSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.78), // inner dark shadow
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 1.0,
      ),
    );

    final TextPainter tpCore = TextPainter(text: coreSpan, textDirection: TextDirection.ltr)
      ..layout(maxWidth: frontRect.width - horizontalPadding / 2);
    final TextPainter tpLight = TextPainter(text: lightSpan, textDirection: TextDirection.ltr)
      ..layout(maxWidth: frontRect.width - horizontalPadding / 2);
    final TextPainter tpDark = TextPainter(text: darkSpan, textDirection: TextDirection.ltr)
      ..layout(maxWidth: frontRect.width - horizontalPadding / 2);

    final double tx = frontRect.left + (frontRect.width - tpCore.width) / 2;
    final double ty = frontRect.top + (frontRect.height - tpCore.height) / 2 + 0.6;

    // paint the dark inset (offset down-right) -> simulates the carved depth
    canvas.save();
    canvas.translate(engravingDepth, engravingDepth);
    tpDark.paint(canvas, Offset(tx, ty));
    canvas.restore();

    // paint the light highlight (offset up-left)
    canvas.save();
    canvas.translate(-engravingDepth * 0.45, -engravingDepth * 0.45);
    tpLight.paint(canvas, Offset(tx, ty));
    canvas.restore();

    // core fill (center, slightly lower to look inset)
    tpCore.paint(canvas, Offset(tx, ty + 0.2));
  }

  @override
  bool shouldRepaint(covariant _StoneTextPainter oldDelegate) => false;
}
