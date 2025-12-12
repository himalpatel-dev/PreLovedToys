import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../utils/flutter_shapes.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;

  const OtpScreen({super.key, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // --- OTP STATE ---
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  // --- TIMER STATE ---
  Timer? _timer;
  int _start = 30; // 30 seconds countdown
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimer(); // Start timer as soon as screen loads
  }

  @override
  void dispose() {
    _timer?.cancel(); // STOP timer when leaving screen to prevent crashes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Timer Logic
  void startTimer() {
    setState(() {
      _isResendEnabled = false;
      _start = 20;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendEnabled = true; // Enable button
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  // Format 00:09 etc.
  String get timerText {
    return "00:${_start.toString().padLeft(2, '0')}";
  }

  // Resend Logic
  void _handleResend() async {
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).sendOtp(widget.mobile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Resent Successfully!')),
        );
        startTimer(); // Restart the 30s counter
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _handleVerify() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit OTP')),
      );
      return;
    }

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).verifyOtp(widget.mobile, otp);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // --- BACKGROUND LAYER ---
          Positioned(
            top: -80,
            left: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(180),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.52,
            right: -30,
            child: CustomPaint(
              size: const Size(130, 130),
              painter: BallPainter(
                color: AppColors.primary.withAlpha(150),
                stripeColor: AppColors.primary.withAlpha(80),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.89,
            right: -40,
            child: CustomPaint(
              size: const Size(120, 120),
              painter: StarPainter(AppColors.primary.withAlpha(218)),
            ),
          ),
          Positioned(
            top: size.height * 0.08,
            right: -20,
            child: Transform.rotate(
              angle: 5.9,
              child: CustomPaint(
                size: const Size(120, 130),
                painter: TeddyPainter(
                  bodyColor: AppColors.primary.withAlpha(218),
                  eyeColor: AppColors.primary,
                  noseColor: AppColors.primary.withAlpha(118),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.55,
            left: -10,
            child: Transform.rotate(
              angle: 0.3,
              child: CustomPaint(
                size: const Size(120, 130),
                painter: GiftBoxPainter(
                  boxColor: AppColors.light.withAlpha(188),
                  ribbonColor: AppColors.primary,
                ),
              ),
            ),
          ),

          // --- CONTENT LAYER ---
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 60),

                            // Title & Mobile Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Verification',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Enter the 4-digit code sent to',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '+91 ${widget.mobile}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: const Text(
                                        "Change",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const Spacer(),

                            // --- 4 OTP UNDERSCORES ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(4, (index) {
                                return SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    cursorColor: AppColors.primary,
                                    onChanged: (value) =>
                                        _onOtpChanged(value, index),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      filled: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.medium,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 30),

                            // Verify Button
                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _handleVerify,
                                child: const Text(
                                  'Verify & Login',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // --- RESEND OTP SECTION (FIXED HEIGHT) ---
                            // Wrapping this in SizedBox(height: 50) stops the UI from jumping
                            SizedBox(
                              height: 40,
                              child: Center(
                                child: _isResendEnabled
                                    ? TextButton(
                                        onPressed: _handleResend,
                                        child: const Text(
                                          "Resend OTP",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : RichText(
                                        text: TextSpan(
                                          text: "Resend code in ",
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: timerText,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            // Use AbsorbPointer to block interactions with underlying widgets.
            AbsorbPointer(
              absorbing: true,
              child: Container(
                // cover entire screen
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.25),
                child: const Center(child: BouncingDiceLoader()),
              ),
            ),
        ],
      ),
    );
  }
}
