import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/auth_layout.dart';
import '../widgets/brand_logo.dart';
import 'login_screen.dart';

/// How long the splash stays up at least, so its animation can be seen.
const Duration _minSplash = Duration(seconds: 2);

/// First screen: an animated splash. Signs the user straight in when a saved session is
/// still valid, otherwise moves on to the login screen (the logo glides into its header).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _rings;
  late final AnimationController _glow;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _rings = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _intro, curve: const Interval(0, 0.9, curve: Curves.easeOutCubic)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _intro.value = 1;
      _rings.stop();
      _glow.stop();
    } else {
      if (!_rings.isAnimating) _rings.repeat();
      if (!_glow.isAnimating) _glow.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _rings.dispose();
    _glow.dispose();
    super.dispose();
  }

  Future<void> _decide() async {
    final results = await Future.wait<bool>([
      context.read<AuthProvider>().tryAutoLogin(),
      Future<bool>.delayed(_minSplash, () => false),
    ]);
    if (!mounted) return;
    if (results.first) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // Same soft circles as the login header, so the hand-over is seamless.
            Positioned(top: -60, left: -50, child: _circle(180, Colors.white.withAlpha(18))),
            Positioned(bottom: -70, right: -40, child: _circle(200, Colors.white.withAlpha(14))),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Spacer(flex: 5),
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rings pulsing out from the logo
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _rings,
                                  builder: (_, _) => CustomPaint(painter: _RingsPainter(_rings.value)),
                                ),
                              ),
                              // Logo with a slow breathing glow
                              AnimatedBuilder(
                                animation: _glow,
                                builder: (_, child) {
                                  final g = _glow.value;
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(92 * 0.28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.08 + g * 0.2),
                                          blurRadius: 18 + g * 22,
                                          spreadRadius: 2 + g * 10,
                                        ),
                                      ],
                                    ),
                                    child: child,
                                  );
                                },
                                child: const Hero(tag: brandLogoHeroTag, child: BrandLogo(size: 92)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'PreLoved Toys',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Memories never go out of play',
                          style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13.5, letterSpacing: 0.2),
                        ),
                        const Spacer(flex: 6),
                        const _LoadingDots(),
                        const SizedBox(height: 52),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Three thin rings that grow out of the logo and fade away, one after another.
class _RingsPainter extends CustomPainter {
  final double progress;

  const _RingsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const minR = 56.0;
    const maxR = 138.0;
    const rings = 3;

    for (var i = 0; i < rings; i++) {
      final t = (progress + i / rings) % 1.0;
      final eased = t * t * (3 - 2 * t); // smoothstep
      canvas.drawCircle(
        center,
        minR + (maxR - minR) * eased,
        Paint()
          ..color = Colors.white.withValues(alpha: (1 - t) * 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 - eased * 0.6,
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.progress != progress;
}

/// Three dots that grow and brighten in turn.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  // One up-and-down cycle of a dot is 1100ms; each dot starts 170ms after the one before.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
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
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) _dot(_level(i)),
        ],
      ),
    );
  }

  /// 0..1 for dot [i]: rises for half the cycle, falls for the other half.
  double _level(int i) {
    final phase = (_controller.value - i * 170 / 1100) % 1.0;
    final triangle = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
    return Curves.easeInOut.transform(triangle.clamp(0.0, 1.0));
  }

  Widget _dot(double v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Opacity(
        opacity: 0.25 + v * 0.75,
        child: Transform.scale(
          scale: 0.75 + v * 0.25,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)],
            ),
          ),
        ),
      ),
    );
  }
}
