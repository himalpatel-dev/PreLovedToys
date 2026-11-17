import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/error_message.dart';
import '../widgets/auth_layout.dart';
import 'otp_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_and_conditions_screen.dart';

/// Indian mobile numbers: 10 digits, starting with 6, 7, 8 or 9.
final RegExp _validMobile = RegExp(r'^[6-9]\d{9}$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final FocusNode _mobileFocus = FocusNode();
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  /// Validation messages appear only after the first attempt to continue.
  bool _attempted = false;

  /// Error returned by the server (e.g. blocked account, no connection).
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () => _open(const TermsAndConditionsScreen());
    _privacyTap = TapGestureRecognizer()..onTap = () => _open(const PrivacyPolicyScreen());
    _mobileFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocus.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  String get _mobile => _mobileController.text;
  bool get _isValid => _validMobile.hasMatch(_mobile);

  /// What is wrong with the number, or null when it's fine (or too early to say).
  String? get _fieldError {
    if (_mobile.isEmpty) return _attempted ? 'Enter your mobile number' : null;
    if (!RegExp(r'^[6-9]').hasMatch(_mobile)) return 'Mobile numbers start with 6, 7, 8 or 9';
    if (_mobile.length < 10 && _attempted) return 'Enter all 10 digits';
    return null;
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _attempted = true;
      _serverError = null;
    });
    if (!_isValid) return;

    final mobile = _mobile;
    try {
      final response = await context.read<AuthProvider>().sendOtp(mobile);
      if (!mounted) return;

      // The development backend returns the code; show it only in debug builds.
      if (kDebugMode && response is Map && response['otp'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug build: your code is ${response['otp']}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      Navigator.of(context).push(fadeRoute(OtpScreen(mobile: mobile)));
    } catch (e) {
      if (mounted) setState(() => _serverError = friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final error = _serverError ?? _fieldError;

    return AuthLayout(
      cardTarget: 300,
      cardChildren: (s) => [
        const Spacer(flex: 3),
        Text(
          'Log in or sign up',
          style: TextStyle(fontSize: 20 * s, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        SizedBox(height: 4 * s),
        const Spacer(flex: 1),
        Text(
          // ‑ is a non-breaking hyphen, so "4-digit" never splits across lines.
          "Enter your mobile number and we'll text you a 4‑digit code. New here? We'll create your account.",
          style: TextStyle(fontSize: 13 * s, height: 1.4, color: AppColors.textLight),
        ),
        const Spacer(flex: 2),
        Text(
          'Mobile number',
          style: TextStyle(fontSize: 12 * s, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        SizedBox(height: 6 * s),
        _buildPhoneField(hasError: error != null, s: s),
        if (error != null) AuthErrorText(error, scale: s),
        const Spacer(flex: 3),
        AuthButton(
          label: 'Get OTP',
          busyLabel: 'Sending code…',
          icon: Icons.arrow_forward_rounded,
          ready: _isValid,
          busy: isLoading,
          onPressed: _sendOtp,
          scale: s,
        ),
        SizedBox(height: 10 * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 14 * s, color: AppColors.medium),
            SizedBox(width: 6 * s),
            Flexible(
              child: Text(
                'No password needed. Your number stays private.',
                style: TextStyle(fontSize: 11.5 * s, color: AppColors.textLight),
              ),
            ),
          ],
        ),
        const Spacer(flex: 2),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 10.7 * s, height: 1.5, color: AppColors.textLight),
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(text: 'Terms & Conditions', style: _linkStyle, recognizer: _termsTap),
              const TextSpan(text: ' and '),
              TextSpan(text: 'Privacy Policy', style: _linkStyle, recognizer: _privacyTap),
              const TextSpan(text: '.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8 * s),
      ],
    );
  }

  static const TextStyle _linkStyle = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  Widget _buildPhoneField({required bool hasError, required double s}) {
    final focused = _mobileFocus.hasFocus;
    final borderColor = hasError
        ? Colors.red.shade400
        : focused
        ? AppColors.primary
        : AppColors.light;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 48 * s,
      decoration: BoxDecoration(
        color: focused ? Colors.white : const Color(0xFFF6F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: focused || hasError ? 1.8 : 1.2),
      ),
      child: Row(
        children: [
          SizedBox(width: 14 * s),
          Text('🇮🇳', style: TextStyle(fontSize: 18 * s)),
          SizedBox(width: 6 * s),
          Text(
            '+91',
            style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          Container(
            width: 1,
            height: 24 * s,
            margin: EdgeInsets.symmetric(horizontal: 12 * s),
            color: AppColors.light,
          ),
          Expanded(
            child: TextField(
              controller: _mobileController,
              focusNode: _mobileFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.go,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [_MobileNumberFormatter()],
              cursorColor: AppColors.primary,
              style: TextStyle(
                fontSize: 17 * s,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  fontSize: 16 * s,
                  letterSpacing: 1.5,
                  color: AppColors.medium,
                  fontWeight: FontWeight.w400,
                ),
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
              onChanged: (_) => setState(() => _serverError = null),
              onSubmitted: (_) => _sendOtp(),
            ),
          ),
          if (_isValid)
            Padding(
              padding: EdgeInsets.only(right: 12 * s),
              child: Icon(Icons.check_circle_rounded, color: const Color(0xFF2E9E5B), size: 20 * s),
            )
          else if (_mobile.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tightFor(width: 40 * s, height: 40 * s),
              icon: Icon(Icons.cancel_rounded, color: AppColors.medium, size: 18 * s),
              onPressed: () => setState(() {
                _mobileController.clear();
                _serverError = null;
              }),
            )
          else
            SizedBox(width: 12 * s),
        ],
      ),
    );
  }
}

/// Keeps only digits, max 10. A pasted "+91 98765 43210" or "098765 43210" becomes "9876543210".
class _MobileNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10 && digits.startsWith('91')) digits = digits.substring(2);
    if (digits.length > 10 && digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length > 10) digits = digits.substring(0, 10);
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
