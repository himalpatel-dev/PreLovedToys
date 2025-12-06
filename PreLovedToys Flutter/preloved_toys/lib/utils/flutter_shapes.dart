// flutter_shapes.dart
// Single-file collection of reusable CustomPainters and helper widgets
// Usage:
// 1) Put this file under lib/widgets/flutter_shapes.dart (or any path you like)
// 2) import it: import 'package:your_app/widgets/flutter_shapes.dart';
// 3) Use one of the helper widgets or the painters directly:
//    // Star
//    Positioned(
//      top: size.height * 0.85,
//      right: -50,
//      child: Shapes.star(size: const Size(120,120), color: Colors.orange.withAlpha(200)),
//    ),
//    // Teddy
//    Positioned(
//      top: size.height * 0.80,
//      right: -40,
//      child: Shapes.teddy(size: const Size(140,170), bodyColor: Color(0xFF8B5E3C)),
//    );

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A single place to store reusable shape painters and small widget helpers.
/// Add more painters here as you need.
class Shapes {
  // Helper that returns a Widget containing a CustomPaint for the star
  static Widget star({
    required Size size,
    Color color = Colors.yellow,
    bool withGlow = false,
  }) {
    Widget painter = CustomPaint(size: size, painter: StarPainter(color));

    if (!withGlow) return painter;

    // Simple glow effect: stack a blurred larger star behind
    return Stack(
      alignment: Alignment.center,
      children: [
        // blurred glow using a larger, translucent star
        Opacity(
          opacity: 0.18,
          child: Transform.scale(
            scale: 1.4,
            child: CustomPaint(
              size: size,
              painter: StarPainter(color.withAlpha(160)),
            ),
          ),
        ),
        painter,
      ],
    );
  }

  // Helper that returns a Widget containing a CustomPaint for the teddy
  static Widget teddy({
    required Size size,
    Color bodyColor = const Color(0xFF8B5E3C),
    Color bellyColor = const Color(0xFFD9B89A),
    Color eyeColor = Colors.black,
  }) {
    return CustomPaint(
      size: size,
      painter: TeddyPainter(
        bodyColor: bodyColor,
        bellyColor: bellyColor,
        eyeColor: eyeColor,
      ),
    );
  }

  // New toy helpers
  static Widget ball({
    required Size size,
    Color color = Colors.red,
    Color stripeColor = Colors.white,
  }) {
    return CustomPaint(
      size: size,
      painter: BallPainter(color: color, stripeColor: stripeColor),
    );
  }

  static Widget balloon({
    required Size size,
    Color color = Colors.pink,
    Color stringColor = Colors.black54,
  }) {
    return CustomPaint(
      size: size,
      painter: BalloonPainter(balloonColor: color, stringColor: stringColor),
    );
  }

  static Widget giftBox({
    required Size size,
    Color boxColor = Colors.blue,
    Color ribbonColor = Colors.red,
  }) {
    return CustomPaint(
      size: size,
      painter: GiftBoxPainter(boxColor: boxColor, ribbonColor: ribbonColor),
    );
  }

  static Widget rocket({
    required Size size,
    Color bodyColor = Colors.grey,
    Color accentColor = Colors.red,
  }) {
    return CustomPaint(
      size: size,
      painter: RocketPainter(bodyColor: bodyColor, accentColor: accentColor),
    );
  }

  static Widget toyCar({
    required Size size,
    Color bodyColor = Colors.green,
    Color wheelColor = Colors.black,
  }) {
    return CustomPaint(
      size: size,
      painter: ToyCarPainter(bodyColor: bodyColor, wheelColor: wheelColor),
    );
  }
}

/// ---------------------
/// StarPainter
/// ---------------------
class StarPainter extends CustomPainter {
  final Color color;
  StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerRadius = math.min(size.width, size.height) / 2;
    final double innerRadius = outerRadius * 0.45;

    for (int i = 0; i < 10; i++) {
      final double angle = (i * 36.0 - 90.0) * (math.pi / 180.0);
      final double radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final double x = cx + radius * math.cos(angle);
      final double y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// ---------------------
/// TeddyPainter
/// ---------------------
class TeddyPainter extends CustomPainter {
  final Color bodyColor;
  final Color bellyColor;
  final Color eyeColor;
  final Color noseColor;

  TeddyPainter({
    this.bodyColor = const Color(0xFF8B5E3C),
    this.bellyColor = const Color(0xFFD9B89A),
    this.eyeColor = Colors.black,
    this.noseColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()..color = bodyColor;
    final Paint bellyPaint = Paint()..color = bellyColor;
    final Paint eyePaint = Paint()..color = eyeColor;
    final Paint highlight = Paint()
      ..color = Colors.white.withAlpha(170)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final headRadius = size.width * 0.22;
    final earRadius = headRadius * 0.6;
    final bodyWidth = size.width * 0.72;
    final bodyHeight = size.height * 0.52;
    final bodyTop = size.height * 0.38;
    final bodyCenterX = cx;
    final bodyCenterY = bodyTop + bodyHeight / 2;

    // Body
    final Rect bodyRect = Rect.fromCenter(
      center: Offset(bodyCenterX, bodyCenterY),
      width: bodyWidth,
      height: bodyHeight,
    );
    final RRect bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(bodyWidth * 0.35),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Belly
    final Rect bellyRect = Rect.fromCenter(
      center: Offset(bodyCenterX, bodyCenterY + bodyHeight * 0.05),
      width: bodyWidth * 0.58,
      height: bodyHeight * 0.64,
    );
    canvas.drawOval(bellyRect, bellyPaint);

    // Head
    final headCenter = Offset(cx, size.height * 0.20 + headRadius * 0.1);
    canvas.drawCircle(headCenter, headRadius, bodyPaint);

    // Ears
    final leftEarCenter = Offset(
      headCenter.dx - headRadius * 0.9,
      headCenter.dy - headRadius * 0.6,
    );
    final rightEarCenter = Offset(
      headCenter.dx + headRadius * 0.9,
      headCenter.dy - headRadius * 0.6,
    );
    canvas.drawCircle(leftEarCenter, earRadius, bodyPaint);
    canvas.drawCircle(rightEarCenter, earRadius, bodyPaint);

    // Inner ears
    final Paint innerEar = Paint()..color = bellyColor;
    canvas.drawCircle(
      Offset(
        leftEarCenter.dx - earRadius * 0.05,
        leftEarCenter.dy - earRadius * 0.05,
      ),
      earRadius * 0.56,
      innerEar,
    );
    canvas.drawCircle(
      Offset(
        rightEarCenter.dx - earRadius * 0.05,
        rightEarCenter.dy - earRadius * 0.05,
      ),
      earRadius * 0.56,
      innerEar,
    );

    // Muzzle
    final muzzleCenter = Offset(
      headCenter.dx,
      headCenter.dy + headRadius * 0.22,
    );
    final muzzleRadiusX = headRadius * 0.72;
    final muzzleRadiusY = headRadius * 0.48;
    final Rect muzzleRect = Rect.fromCenter(
      center: muzzleCenter,
      width: muzzleRadiusX * 2,
      height: muzzleRadiusY * 2,
    );
    canvas.drawOval(muzzleRect, bellyPaint);

    // Nose
    final nosePaint = Paint()..color = noseColor;
    final noseCenter = Offset(
      muzzleCenter.dx,
      muzzleCenter.dy - muzzleRadiusY * 0.05,
    );
    final Path nosePath = Path()
      ..moveTo(noseCenter.dx, noseCenter.dy)
      ..relativeQuadraticBezierTo(-6, 10, 0, 18)
      ..relativeQuadraticBezierTo(6, -8, 0, -18)
      ..close();
    final noseScale = headRadius / 18;
    canvas.save();
    canvas.translate(noseCenter.dx, noseCenter.dy);
    canvas.scale(noseScale, noseScale);
    canvas.translate(-noseCenter.dx, -noseCenter.dy);
    canvas.drawPath(nosePath, nosePaint);
    canvas.restore();

    // Smile lines
    final smilePaint = Paint()
      ..color = Colors.black.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, headRadius * 0.06)
      ..strokeCap = StrokeCap.round;
    final leftSmile = Path();
    leftSmile.moveTo(noseCenter.dx, noseCenter.dy + headRadius * 0.08);
    leftSmile.quadraticBezierTo(
      noseCenter.dx - headRadius * 0.28,
      noseCenter.dy + headRadius * 0.38,
      noseCenter.dx - headRadius * 0.44,
      noseCenter.dy + headRadius * 0.48,
    );
    canvas.drawPath(leftSmile, smilePaint);

    final rightSmile = Path();
    rightSmile.moveTo(noseCenter.dx, noseCenter.dy + headRadius * 0.08);
    rightSmile.quadraticBezierTo(
      noseCenter.dx + headRadius * 0.28,
      noseCenter.dy + headRadius * 0.38,
      noseCenter.dx + headRadius * 0.44,
      noseCenter.dy + headRadius * 0.48,
    );
    canvas.drawPath(rightSmile, smilePaint);

    // Eyes
    final eyeOffsetX = headRadius * 0.45;
    final eyeOffsetY = headRadius * -0.08;
    final eyeRadius = headRadius * 0.14;
    final leftEye = Offset(
      headCenter.dx - eyeOffsetX,
      headCenter.dy + eyeOffsetY,
    );
    final rightEye = Offset(
      headCenter.dx + eyeOffsetX,
      headCenter.dy + eyeOffsetY,
    );
    canvas.drawCircle(leftEye, eyeRadius, eyePaint);
    canvas.drawCircle(rightEye, eyeRadius, eyePaint);

    // Eye highlights
    canvas.drawCircle(
      Offset(leftEye.dx - eyeRadius * 0.35, leftEye.dy - eyeRadius * 0.35),
      eyeRadius * 0.36,
      highlight,
    );
    canvas.drawCircle(
      Offset(rightEye.dx - eyeRadius * 0.35, rightEye.dy - eyeRadius * 0.35),
      eyeRadius * 0.36,
      highlight,
    );

    // Arms
    final armWidth = bodyWidth * 0.46;
    final armHeight = bodyHeight * 0.34;
    final leftArmRect = Rect.fromCenter(
      center: Offset(
        bodyRect.left + armWidth * 0.2,
        bodyRect.center.dy - bodyHeight * 0.08,
      ),
      width: armWidth,
      height: armHeight,
    );
    final rightArmRect = Rect.fromCenter(
      center: Offset(
        bodyRect.right - armWidth * 0.2,
        bodyRect.center.dy - bodyHeight * 0.08,
      ),
      width: armWidth,
      height: armHeight,
    );
    canvas.drawOval(leftArmRect, bodyPaint);
    canvas.drawOval(rightArmRect, bodyPaint);

    // Legs
    final legWidth = bodyWidth * 0.44;
    final legHeight = bodyHeight * 0.32;
    final leftLegRect = Rect.fromCenter(
      center: Offset(
        bodyRect.center.dx - bodyWidth * 0.28,
        bodyRect.bottom - legHeight * 0.18,
      ),
      width: legWidth,
      height: legHeight,
    );
    final rightLegRect = Rect.fromCenter(
      center: Offset(
        bodyRect.center.dx + bodyWidth * 0.28,
        bodyRect.bottom - legHeight * 0.18,
      ),
      width: legWidth,
      height: legHeight,
    );
    canvas.drawOval(leftLegRect, bodyPaint);
    canvas.drawOval(rightLegRect, bodyPaint);

    // Paw pads
    final pawPaint = Paint()..color = bellyColor.withAlpha(195);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          leftLegRect.center.dx,
          leftLegRect.center.dy + legHeight * 0.08,
        ),
        width: legWidth * 0.6,
        height: legHeight * 0.36,
      ),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          rightLegRect.center.dx,
          rightLegRect.center.dy + legHeight * 0.08,
        ),
        width: legWidth * 0.6,
        height: legHeight * 0.36,
      ),
      pawPaint,
    );

    // Subtle shadow
    final shadowPaint = Paint()..color = Colors.black.withAlpha(12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyCenterX, bodyRect.bottom + bodyHeight * 0.06),
        width: bodyWidth * 0.9,
        height: bodyHeight * 0.18,
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ---------------------
/// BallPainter
/// Simple colorful ball with two stripes
/// ---------------------
class BallPainter extends CustomPainter {
  final Color color;
  final Color stripeColor;

  BallPainter({this.color = Colors.red, this.stripeColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(Offset(cx, cy), radius, paint);

    final Paint stripe = Paint()
      ..color = stripeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.round;

    // Draw two curved stripes
    final Path p1 = Path();
    p1.moveTo(cx - radius * 0.7, cy - radius * 0.2);
    p1.quadraticBezierTo(
      cx,
      cy - radius * 0.5,
      cx + radius * 0.7,
      cy - radius * 0.2,
    );
    canvas.drawPath(p1, stripe);

    final Path p2 = Path();
    p2.moveTo(cx - radius * 0.6, cy + radius * 0.25);
    p2.quadraticBezierTo(
      cx,
      cy + radius * 0.55,
      cx + radius * 0.6,
      cy + radius * 0.25,
    );
    canvas.drawPath(p2, stripe);
  }

  @override
  bool shouldRepaint(covariant BallPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.stripeColor != stripeColor;
}

/// ---------------------
/// BalloonPainter
/// ---------------------
class BalloonPainter extends CustomPainter {
  final Color balloonColor;
  final Color stringColor;
  BalloonPainter({
    this.balloonColor = Colors.pink,
    this.stringColor = Colors.black54,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint balloon = Paint()..color = balloonColor;
    final Paint stringPaint = Paint()
      ..color = stringColor
      ..strokeWidth = math.max(1.0, size.width * 0.015)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height * 0.38;
    final rx = size.width * 0.36;
    final ry = size.height * 0.46;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      balloon,
    );

    // highlight
    final Paint highlight = Paint()..color = Colors.white.withAlpha(160);
    canvas.drawCircle(
      Offset(cx - rx * 0.25, cy - ry * 0.35),
      math.min(size.width, size.height) * 0.06,
      highlight,
    );

    // string
    final Path s = Path();
    s.moveTo(cx, cy + ry * 0.6);
    s.relativeQuadraticBezierTo(6, size.height * 0.06, -6, size.height * 0.12);
    s.relativeQuadraticBezierTo(-6, size.height * 0.06, 6, size.height * 0.18);
    canvas.drawPath(s, stringPaint);
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) =>
      oldDelegate.balloonColor != balloonColor ||
      oldDelegate.stringColor != stringColor;
}

/// ---------------------
/// GiftBoxPainter
/// ---------------------
class GiftBoxPainter extends CustomPainter {
  final Color boxColor;
  final Color ribbonColor;
  GiftBoxPainter({this.boxColor = Colors.blue, this.ribbonColor = Colors.red});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint box = Paint()..color = boxColor;
    final Paint ribbon = Paint()..color = ribbonColor;

    final double w = size.width;
    final double h = size.height;
    final Rect boxRect = Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.76, h * 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, Radius.circular(w * 0.06)),
      box,
    );

    // vertical ribbon
    canvas.drawRect(
      Rect.fromLTWH(w * 0.46, h * 0.28, w * 0.08, h * 0.6),
      ribbon,
    );
    // horizontal ribbon
    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, h * 0.46, w * 0.76, h * 0.08),
      ribbon,
    );

    // bow (simple)
    final Path left = Path();
    left.moveTo(w * 0.5, h * 0.2);
    left.relativeLineTo(-w * 0.14, h * 0.08);
    left.relativeQuadraticBezierTo(w * 0.04, h * 0.04, w * 0.08, h * 0.06);
    left.close();
    canvas.drawPath(left, ribbon);

    final Path right = Path();
    right.moveTo(w * 0.5, h * 0.2);
    right.relativeLineTo(w * 0.14, h * 0.08);
    right.relativeQuadraticBezierTo(-w * 0.04, h * 0.04, -w * 0.08, h * 0.06);
    right.close();
    canvas.drawPath(right, ribbon);
  }

  @override
  bool shouldRepaint(covariant GiftBoxPainter oldDelegate) =>
      oldDelegate.boxColor != boxColor ||
      oldDelegate.ribbonColor != ribbonColor;
}

/// ---------------------
/// RocketPainter
/// ---------------------
class RocketPainter extends CustomPainter {
  final Color bodyColor;
  final Color accentColor;
  RocketPainter({this.bodyColor = Colors.grey, this.accentColor = Colors.red});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint body = Paint()..color = bodyColor;
    final Paint accent = Paint()..color = accentColor;
    final double w = size.width;
    final double h = size.height;

    final Path rocket = Path();
    rocket.moveTo(w * 0.5, h * 0.05);
    rocket.quadraticBezierTo(w * 0.8, h * 0.2, w * 0.8, h * 0.5);
    rocket.quadraticBezierTo(w * 0.8, h * 0.8, w * 0.5, h * 0.95);
    rocket.quadraticBezierTo(w * 0.2, h * 0.8, w * 0.2, h * 0.5);
    rocket.quadraticBezierTo(w * 0.2, h * 0.2, w * 0.5, h * 0.05);
    rocket.close();
    canvas.drawPath(rocket, body);

    // window
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), math.min(w, h) * 0.12, accent);

    // fins
    final Path leftFin = Path();
    leftFin.moveTo(w * 0.18, h * 0.7);
    leftFin.lineTo(w * 0.05, h * 0.85);
    leftFin.lineTo(w * 0.25, h * 0.75);
    leftFin.close();
    canvas.drawPath(leftFin, accent);

    final Path rightFin = Path();
    rightFin.moveTo(w * 0.82, h * 0.7);
    rightFin.lineTo(w * 0.95, h * 0.85);
    rightFin.lineTo(w * 0.75, h * 0.75);
    rightFin.close();
    canvas.drawPath(rightFin, accent);
  }

  @override
  bool shouldRepaint(covariant RocketPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.accentColor != accentColor;
}

/// ---------------------
/// ToyCarPainter
/// ---------------------
class ToyCarPainter extends CustomPainter {
  final Color bodyColor;
  final Color wheelColor;
  ToyCarPainter({
    this.bodyColor = Colors.green,
    this.wheelColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint body = Paint()..color = bodyColor;
    final Paint wheel = Paint()..color = wheelColor;
    final double w = size.width;
    final double h = size.height;

    // Car body
    final Rect bodyRect = Rect.fromLTWH(w * 0.08, h * 0.30, w * 0.84, h * 0.42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.06)),
      body,
    );

    // Cabin
    final Path cab = Path();
    cab.moveTo(w * 0.26, h * 0.30);
    cab.lineTo(w * 0.44, h * 0.12);
    cab.lineTo(w * 0.72, h * 0.12);
    cab.lineTo(w * 0.76, h * 0.30);
    cab.close();
    canvas.drawPath(cab, body);

    // Wheels
    final double wheelRadius = math.min(w, h) * 0.12;
    canvas.drawCircle(Offset(w * 0.28, h * 0.72), wheelRadius, wheel);
    canvas.drawCircle(Offset(w * 0.72, h * 0.72), wheelRadius, wheel);

    // Wheel hubs
    final Paint hub = Paint()..color = Colors.white70;
    canvas.drawCircle(Offset(w * 0.28, h * 0.72), wheelRadius * 0.45, hub);
    canvas.drawCircle(Offset(w * 0.72, h * 0.72), wheelRadius * 0.45, hub);
  }

  @override
  bool shouldRepaint(covariant ToyCarPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.wheelColor != wheelColor;
}
