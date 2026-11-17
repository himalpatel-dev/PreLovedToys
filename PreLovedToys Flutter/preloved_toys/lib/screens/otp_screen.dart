import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/error_message.dart';
import '../widgets/auth_layout.dart';
import '../widgets/custom_loader.dart';

/// Number of digits in the code.
const int _codeLength = 4;

/// Width and height of each code box.
const double _boxSize = 48;

/// Seconds before a new code can be requested.
const int _resendAfter = 20;

class OtpScreen extends StatefulWidget {
  final String mobile;

  const OtpScreen({super.key, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  late final TapGestureRecognizer _resendTap;

  Timer? _timer;
  int _secondsLeft = _resendAfter;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resendTap = TapGestureRecognizer()..onTap = _resend;
    _codeFocus.addListener(() => setState(() {}));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _codeFocus.dispose();
    _resendTap.dispose();
    super.dispose();
  }

  bool get _complete => _code.text.length == _codeLength;

  /// "9876543210" -> "98765 43210", with a no-break space so it never splits across lines.
  String get _prettyMobile {
    final m = widget.mobile;
    return m.length == 10 ? '${m.substring(0, 5)} ${m.substring(5)}' : m;
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendAfter;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  Future<void> _verify() async {
    if (_verifying) return;
    if (!_complete) {
      setState(() => _error = 'Enter all $_codeLength digits');
      _codeFocus.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().verifyOtp(widget.mobile, _code.text);
      if (!mounted) return;
      // Clear the login screens so Back doesn't return to them.
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = friendlyError(e);
      });
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending || _verifying) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final response = await context.read<AuthProvider>().sendOtp(widget.mobile);
      if (!mounted) return;
      _code.clear();
      _startTimer();
      // The development backend returns the code; show it only in debug builds.
      final debugCode = kDebugMode && response is Map ? response['otp'] : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(debugCode == null ? 'We sent you a new code' : 'New code sent. Debug build: your code is $debugCode'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;

    return AuthLayout(
      cardTarget: 260,
      overlay: _verifying
          ? ColoredBox(
              color: Colors.white.withValues(alpha: 0.88),
              child: const Center(child: BouncingDiceLoader(color: AppColors.primary)),
            )
          : null,
      cardChildren: (s) => [
        const Spacer(flex: 3),
        Text(
          'Verification',
          style: TextStyle(fontSize: 20 * s, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        SizedBox(height: 4 * s),
        const Spacer(flex: 1),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 13 * s, height: 1.4, color: AppColors.textLight),
            children: [
              // ‑ is a non-breaking hyphen, so "4-digit" never splits across lines.
              const TextSpan(text: 'Enter the 4‑digit code sent to '),
              TextSpan(
                text: _prettyMobile,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              // Word joiner: keeps the edit button on the same line as the number.
              const TextSpan(text: '⁠'),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(left: 6 * s),
                  child: _buildEditButton(s),
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
        _buildCodeField(hasError: error != null, s: s),
        if (error != null) AuthErrorText(error, scale: s),
        const Spacer(flex: 3),
        AuthButton(
          label: 'Verify & Login',
          busyLabel: 'Verifying…',
          icon: Icons.check_rounded,
          ready: _complete,
          busy: _verifying,
          onPressed: _verify,
          scale: s,
        ),
        SizedBox(height: 10 * s),
        const Spacer(flex: 1),
        _buildResendRow(s),
        const Spacer(flex: 2),
      ],
    );
  }

  static const TextStyle _linkStyle = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  Widget _buildResendRow(double s) {
    final base = TextStyle(fontSize: 11.5 * s, color: AppColors.textLight);
    final InlineSpan action;
    if (_resending) {
      action = const TextSpan(text: 'Sending…');
    } else if (_secondsLeft > 0) {
      action = TextSpan(
        text: 'Resend in 00:${_secondsLeft.toString().padLeft(2, '0')}',
        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
      );
    } else {
      action = TextSpan(text: 'Resend OTP', style: _linkStyle, recognizer: _resendTap);
    }
    return Text.rich(
      TextSpan(style: base, children: [const TextSpan(text: "Didn't receive the code? "), action]),
      textAlign: TextAlign.center,
    );
  }

  /// Small pencil next to the number; goes back to the login screen to change it.
  Widget _buildEditButton(double s) {
    return Semantics(
      button: true,
      label: 'Change number',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          padding: EdgeInsets.all(5 * s),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(22), shape: BoxShape.circle),
          child: Icon(Icons.edit_rounded, size: 14 * s, color: AppColors.primary),
        ),
      ),
    );
  }

  /// Four boxes showing the code. Typing goes into one invisible text field laid over
  /// them, so paste, backspace and SMS autofill all work like a normal field.
  Widget _buildCodeField({required bool hasError, required double s}) {
    final focused = _codeFocus.hasFocus;
    final code = _code.text;

    return GestureDetector(
      onTap: () => _codeFocus.requestFocus(),
      child: SizedBox(
        height: _boxSize * s,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                alwaysIncludeSemantics: true,
                child: TextField(
                  controller: _code,
                  focusNode: _codeFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_codeLength),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _verify(),
                ),
              ),
            ),
            IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _codeLength; i++) ...[
                    if (i > 0) SizedBox(width: 14 * s),
                    _buildBox(i, code, focused, hasError, s),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Colours follow the mobile field on the login screen: grey when empty, white with
  /// a teal border for the box being typed into, a light teal tint once filled, red on error.
  Widget _buildBox(int i, String code, bool focused, bool hasError, double s) {
    final digit = i < code.length ? code[i] : '';
    final filled = digit.isNotEmpty;
    // The box the next digit goes into (the last box once the code is complete).
    final active = focused && i == (code.length < _codeLength ? code.length : _codeLength - 1);

    final Color fill;
    final Color border;
    var borderWidth = 1.2;
    if (hasError) {
      fill = Colors.red.shade50;
      border = Colors.red.shade300;
    } else if (active) {
      fill = Colors.white;
      border = AppColors.primary;
      borderWidth = 1.8;
    } else if (filled) {
      fill = AppColors.primary.withAlpha(24);
      border = AppColors.primary.withAlpha(150);
    } else {
      fill = const Color(0xFFF6F7F7);
      border = AppColors.light;
    }

    final Widget content;
    if (filled) {
      content = Text(
        digit,
        key: ValueKey('$i:$digit'),
        style: TextStyle(
          fontSize: 20 * s,
          fontWeight: FontWeight.w700,
          color: hasError ? Colors.red.shade700 : AppColors.primary,
        ),
      );
    } else if (active) {
      // A small caret marks where the next digit goes.
      content = Container(
        key: const ValueKey('caret'),
        width: 2,
        height: 18 * s,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(1)),
      );
    } else {
      content = const SizedBox.shrink(key: ValueKey('empty'));
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: _boxSize * s,
      height: _boxSize * s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: active && !hasError
            ? [BoxShadow(color: AppColors.primary.withAlpha(40), blurRadius: 10, offset: const Offset(0, 3))]
            : null,
      ),
      // Each digit pops in as it's typed.
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: Tween(begin: 0.6, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: content,
      ),
    );
  }
}
