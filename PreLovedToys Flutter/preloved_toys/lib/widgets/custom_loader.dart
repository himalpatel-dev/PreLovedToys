import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(
    MaterialApp(
      // EXAMPLE: Changing this primary color will now automatically change the dice
      theme: ThemeData(primaryColor: Colors.deepPurple),
      home: const Scaffold(body: Center(child: BouncingDiceLoader())),
    ),
  );
}

class BouncingDiceLoader extends StatefulWidget {
  final double size;
  final Color? color; // Changed to nullable to support Theme fallback

  const BouncingDiceLoader({super.key, this.size = 50.0, this.color});

  @override
  State<BouncingDiceLoader> createState() => _BouncingDiceLoaderState();
}

class _BouncingDiceLoaderState extends State<BouncingDiceLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yTranslation;
  late Animation<double> _rotation;
  late Animation<double> _shadowScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _yTranslation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -60.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -60.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _rotation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutBack),
      ),
    );

    _shadowScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 60),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RESOLVE COLOR HERE: Use the passed color, or fallback to Theme Primary Color
    final Color effectiveColor = widget.color ?? Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [_buildBouncingDie(0, effectiveColor)],
        );
      },
    );
  }

  Widget _buildBouncingDie(double offset, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: Offset(0, _yTranslation.value),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_rotation.value + (offset * math.pi))
              ..rotateY(_rotation.value + (offset * math.pi)),
            alignment: Alignment.center,
            child: _buildCube(color), // Pass color down
          ),
        ),
        const SizedBox(height: 10),
        Transform.scale(
          scale: _shadowScale.value,
          child: Container(
            width: widget.size,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.all(
                Radius.elliptical(widget.size, 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCube(Color color) {
    double halfSize = widget.size / 2;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          _buildFace(0, 0, halfSize, 1, color),
          _buildFace(math.pi, 0, halfSize, 6, color),
          _buildFace(0, math.pi / 2, halfSize, 3, color),
          _buildFace(0, -math.pi / 2, halfSize, 4, color),
          _buildFace(-math.pi / 2, 0, halfSize, 2, color),
          _buildFace(math.pi / 2, 0, halfSize, 5, color),
        ],
      ),
    );
  }

  Widget _buildFace(
    double xRot,
    double yRot,
    double translateZ,
    int pips,
    Color color,
  ) {
    return Positioned.fill(
      child: Transform(
        transform: Matrix4.identity()
          ..rotateX(xRot)
          ..rotateY(yRot)
          // ignore: deprecated_member_use
          ..translate(0.0, 0.0, translateZ),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: color, // Use the effective color
            borderRadius: BorderRadius.circular(widget.size * 0.05),
            border: Border.all(color: Colors.white.withAlpha(230), width: 2),
          ),
          child: CustomPaint(painter: DicePipsPainter(pips: pips)),
        ),
      ),
    );
  }
}

class DicePipsPainter extends CustomPainter {
  final int pips;
  DicePipsPainter({required this.pips});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    double r = size.width * 0.1;
    double c = size.width / 2;
    double l = size.width * 0.25;
    double rg = size.width * 0.75;

    void d(double x, double y) => canvas.drawCircle(Offset(x, y), r, paint);

    if (pips % 2 != 0) d(c, c);
    if (pips > 1) {
      d(l, l);
      d(rg, rg);
    }
    if (pips > 3) {
      d(rg, l);
      d(l, rg);
    }
    if (pips == 6) {
      d(l, c);
      d(rg, c);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
