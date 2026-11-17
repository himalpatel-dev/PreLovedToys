import 'package:flutter/material.dart';

/// The PreLoved Toys mark: a teddy face on a white rounded tile.
class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: const CustomPaint(painter: TeddyFacePainter()),
    );
  }
}

/// A simple, friendly teddy head that stays readable at small sizes.
class TeddyFacePainter extends CustomPainter {
  final Color fur;
  final Color muzzle;
  final Color features;
  final Color cheeks;

  const TeddyFacePainter({
    this.fur = const Color(0xFFB98552),
    this.muzzle = const Color(0xFFF1D9B5),
    this.features = const Color(0xFF3B2A1E),
    this.cheeks = const Color(0x66F2A7A0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final dx = (size.width - s) / 2;
    final dy = (size.height - s) / 2;
    Offset p(double x, double y) => Offset(dx + x * s, dy + y * s);

    final furPaint = Paint()..color = fur;
    final muzzlePaint = Paint()..color = muzzle;
    final featurePaint = Paint()..color = features;

    // Ears (behind the head)
    for (final x in [0.22, 0.78]) {
      canvas.drawCircle(p(x, 0.26), s * 0.16, furPaint);
      canvas.drawCircle(p(x, 0.26), s * 0.085, muzzlePaint);
    }

    // Head
    canvas.drawCircle(p(0.5, 0.56), s * 0.37, furPaint);

    // Cheeks
    final cheekPaint = Paint()..color = cheeks;
    canvas.drawCircle(p(0.27, 0.66), s * 0.06, cheekPaint);
    canvas.drawCircle(p(0.73, 0.66), s * 0.06, cheekPaint);

    // Muzzle
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.7), width: s * 0.38, height: s * 0.28), muzzlePaint);

    // Eyes with a small highlight
    final highlight = Paint()..color = Colors.white;
    for (final x in [0.37, 0.63]) {
      canvas.drawCircle(p(x, 0.5), s * 0.045, featurePaint);
      canvas.drawCircle(p(x - 0.015, 0.485), s * 0.015, highlight);
    }

    // Button nose
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: p(0.5, 0.635), width: s * 0.14, height: s * 0.095),
        Radius.circular(s * 0.05),
      ),
      featurePaint,
    );

    // Smile
    final smile = Paint()
      ..color = features
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(p(0.5, 0.68).dx, p(0.5, 0.68).dy)
      ..lineTo(p(0.5, 0.72).dx, p(0.5, 0.72).dy)
      ..moveTo(p(0.42, 0.73).dx, p(0.42, 0.73).dy)
      ..quadraticBezierTo(p(0.5, 0.79).dx, p(0.5, 0.79).dy, p(0.58, 0.73).dx, p(0.58, 0.73).dy);
    canvas.drawPath(mouth, smile);
  }

  @override
  bool shouldRepaint(covariant TeddyFacePainter old) =>
      old.fur != fur || old.muzzle != muzzle || old.features != features || old.cheeks != cheeks;
}
