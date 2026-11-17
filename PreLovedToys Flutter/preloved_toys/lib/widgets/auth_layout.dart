import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/flutter_shapes.dart';
import 'brand_logo.dart';
import 'glare_sweep.dart';

/// Hero tag shared by the logo on the splash, login and OTP screens.
const String brandLogoHeroTag = 'brand-logo';

/// The header takes the top 65% of the screen.
const double _headerFraction = 0.65;

/// How far the white card overlaps the bottom of the header.
const double _cardOverlap = 40;

const Duration _move = Duration(milliseconds: 220);

/// Soft yellow used for the category circles on the home screen.
const Color _warm = Color(0xFFF8E9B7);

/// Fade between screens of the login flow: 400ms forward, 300ms back.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    ),
  );
}

/// Page layout for the login flow: a teal header with the logo on the top 65% of the
/// screen, and a white card that overlaps it by 40px and fills the rest. When the
/// keyboard opens, the card rides up above it and the header shrinks.
class AuthLayout extends StatelessWidget {
  /// Card height at which the card's contents are drawn at 1x. Shorter cards scale them down.
  final double cardTarget;

  /// The card's column children, built for content scale `s`. Use [Spacer]s to spread them.
  final List<Widget> Function(double s) cardChildren;

  /// Drawn over the whole page, e.g. a loading overlay.
  final Widget? overlay;

  const AuthLayout({super.key, required this.cardTarget, required this.cardChildren, this.overlay});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final safeTop = media.padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        // The card moves above the keyboard by itself, so the page isn't resized.
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              final headerHeight = height * _headerFraction;
              // The card starts 40px above the end of the header and rides up with the keyboard.
              final cardTop = (headerHeight - _cardOverlap - keyboard).clamp(safeTop + 40, double.infinity);
              // Header contents scale with the screen, using an 800px-tall phone as the reference.
              final headerScale = (height / 800).clamp(0.78, 1.15);

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: _move,
                    curve: Curves.easeOut,
                    top: 0,
                    left: 0,
                    right: 0,
                    height: cardTop + _cardOverlap,
                    child: _AuthHeader(compact: keyboard > 0, scale: headerScale, overlap: _cardOverlap),
                  ),
                  // White behind the card so no teal shows while the card follows the keyboard.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: height * (1 - _headerFraction),
                    child: const ColoredBox(color: Colors.white),
                  ),
                  AnimatedPositioned(
                    duration: _move,
                    curve: Curves.easeOut,
                    top: cardTop,
                    left: 0,
                    right: 0,
                    bottom: keyboard,
                    child: _buildCard(),
                  ),
                  if (overlay != null) Positioned.fill(child: overlay!),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    // The card fades and slides up as the screen opens.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final s = (constraints.maxHeight / cardTarget).clamp(0.55, 1.05);
              final padV = 8 * s;

              // Fills the card and spreads the spare height between the Spacers. If the
              // contents ever don't fit (e.g. very large system font), the card scrolls.
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: padV),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - padV * 2).clamp(0.0, double.infinity),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: cardChildren(s),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Main action button of the login flow: 45px tall, with a glare sweeping across it.
/// Looks faded until [ready], but stays tappable so a tap can explain what's missing.
class AuthButton extends StatelessWidget {
  final String label;
  final String busyLabel;
  final IconData icon;
  final bool ready;
  final bool busy;
  final VoidCallback onPressed;
  final double scale;

  const AuthButton({
    super.key,
    required this.label,
    required this.busyLabel,
    required this.icon,
    required this.ready,
    required this.busy,
    required this.onPressed,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final text = TextStyle(fontSize: 16 * s);
    final faded = AppColors.primary.withAlpha(110);

    return GlareSweep(
      borderRadius: BorderRadius.circular(30),
      bandWidth: 65 * s,
      enabled: !busy,
      child: SizedBox(
        height: 45 * s,
        child: ElevatedButton(
          onPressed: busy ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 18 * s),
            backgroundColor: ready ? AppColors.primary : faded,
            disabledBackgroundColor: faded,
            disabledForegroundColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: busy
                ? [
                    SizedBox(
                      width: 18 * s,
                      height: 18 * s,
                      child: const CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    ),
                    SizedBox(width: 10 * s),
                    Text(busyLabel, style: text),
                  ]
                : [
                    Text(label, style: text),
                    SizedBox(width: 8 * s),
                    Icon(icon, size: 18 * s),
                  ],
          ),
        ),
      ),
    );
  }
}

/// A red error line shown under a field.
class AuthErrorText extends StatelessWidget {
  final String message;
  final double scale;

  const AuthErrorText(this.message, {super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Padding(
      padding: EdgeInsets.only(top: 6 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 16 * s, color: Colors.red.shade700),
          SizedBox(width: 6 * s),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12 * s, height: 1.3, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Teal header with the logo and a scatter of toys. Shrinks while the keyboard is open.
class _AuthHeader extends StatelessWidget {
  final bool compact;

  /// Size multiplier for the logo, text and toys.
  final double scale;

  /// Height at the bottom that is hidden under the card.
  final double overlap;

  const _AuthHeader({required this.compact, required this.scale, required this.overlap});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final s = scale;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Soft background circles
        Positioned(top: -60, left: -50, child: _circle(180 * s, Colors.white.withAlpha(18))),
        Positioned(bottom: overlap - 70, right: -40, child: _circle(200 * s, Colors.white.withAlpha(14))),

        // Toys and logo sit in the part of the header the card doesn't cover.
        Positioned.fill(
          top: topInset,
          bottom: overlap,
          child: LayoutBuilder(
            builder: (context, box) {
              final h = box.maxHeight;
              return Stack(
                children: [
                  // Toys (hidden in compact mode to keep the header calm)
                  _toy(
                    top: h * 0.05,
                    right: 26,
                    angle: 0.35,
                    size: Size.square(58 * s),
                    painter: BallPainter(color: _warm.withAlpha(230), stripeColor: Colors.white.withAlpha(200)),
                  ),
                  _toy(
                    top: h * 0.2,
                    left: 22,
                    angle: -0.25,
                    size: Size(54 * s, 60 * s),
                    painter: GiftBoxPainter(boxColor: Colors.white.withAlpha(60), ribbonColor: _warm.withAlpha(220)),
                  ),
                  _toy(
                    bottom: h * 0.18,
                    left: 30,
                    angle: 0.15,
                    size: Size.square(46 * s),
                    painter: StarPainter(_warm.withAlpha(200)),
                  ),
                  _toy(
                    bottom: h * 0.04,
                    right: 18,
                    angle: -0.08,
                    size: Size.square(84 * s),
                    painter: ToyCarPainter(
                      bodyColor: Colors.white.withAlpha(70),
                      wheelColor: Colors.white.withAlpha(150),
                    ),
                  ),
                  _toy(
                    top: h * 0.3,
                    right: 86,
                    angle: 0.2,
                    size: Size.square(26 * s),
                    painter: StarPainter(Colors.white.withAlpha(90)),
                  ),

                  // Logo + name, scaled down if the space above the keyboard gets tight.
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                width: (compact ? 56 : 92) * s,
                                height: (compact ? 56 : 92) * s,
                                child: const Hero(
                                  tag: brandLogoHeroTag,
                                  child: FittedBox(child: BrandLogo(size: 92)),
                                ),
                              ),
                              SizedBox(height: (compact ? 10 : 16) * s),
                              Text(
                                'PreLoved Toys',
                                style: TextStyle(
                                  fontSize: (compact ? 22 : 30) * s,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: compact
                                    ? const SizedBox(height: 0)
                                    : Padding(
                                        padding: EdgeInsets.only(top: 6 * s),
                                        child: Text(
                                          'Memories never go out of play',
                                          style: TextStyle(fontSize: 15 * s, color: Colors.white.withAlpha(200)),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _toy({
    required double angle,
    required Size size,
    required CustomPainter painter,
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: compact ? 0 : 1,
          child: Transform.rotate(
            angle: angle,
            child: CustomPaint(size: size, painter: painter),
          ),
        ),
      ),
    );
  }
}
