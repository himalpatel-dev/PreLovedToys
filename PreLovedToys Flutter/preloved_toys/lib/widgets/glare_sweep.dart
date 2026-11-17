import 'package:flutter/material.dart';

/// A soft white highlight that sweeps across [child] every 2.4 seconds.
/// Stops when [enabled] is false or the system asks for reduced motion.
class GlareSweep extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final bool enabled;
  final double bandWidth;

  const GlareSweep({
    super.key,
    required this.child,
    required this.borderRadius,
    this.enabled = true,
    this.bandWidth = 65,
  });

  @override
  State<GlareSweep> createState() => _GlareSweepState();
}

class _GlareSweepState extends State<GlareSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final Animation<double> _sweep = CurvedAnimation(parent: _controller, curve: Curves.slowMiddle);

  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(GlareSweep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _running = widget.enabled && !reduceMotion;
    if (_running && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_running) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_running) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: LayoutBuilder(
                builder: (context, box) => AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, _) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        // From just off the left edge to just off the right edge.
                        left: -80 + _sweep.value * (box.maxWidth + 160),
                        top: 0,
                        bottom: 0,
                        child: Transform.rotate(
                          angle: -0.05,
                          child: Container(
                            width: widget.bandWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.28),
                                  Colors.white.withValues(alpha: 0),
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
            ),
          ),
        ),
      ],
    );
  }
}
