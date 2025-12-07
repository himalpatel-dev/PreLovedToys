import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/otp_screen.dart';
import 'package:preloved_toys/utils/flutter_shapes.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileController.text = '9727376727';
  }

  void _handleSendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number')),
      );
      return;
    }

    try {
      // 1. Capture the response into a variable
      final response = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).sendOtp(mobile);

      // 2. Extract OTP (Safely handle if it's null)
      final otp = response['otp'] ?? '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // 3. Show OTP in the message
          SnackBar(
            content: Text('OTP Sent! Code: $otp'),
            backgroundColor: Colors.green,
            duration: const Duration(
              seconds: 4,
            ), // Show it longer so you can read it
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => OtpScreen(mobile: mobile)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
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
          // --- BACKGROUND LAYER (Must be first) ---

          // Top Left Dark Circle
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

          // Top Right Ball
          Positioned(
            top: size.height * 0.10,
            right: 30,
            child: Transform.rotate(
              angle: 150,
              child: CustomPaint(
                size: const Size(100, 100), // Star size
                painter: BallPainter(
                  color: AppColors.primary.withAlpha(188),
                  stripeColor: AppColors.light,
                ),
              ),
            ),
          ),

          // Middle Left Circle
          Positioned(
            top: size.height * 0.39,
            left: -50,
            child: Container(
              width: 120, // Made slightly thinner
              height: 120, // Made slightly shorter
              decoration: BoxDecoration(
                color: AppColors.light.withAlpha(128),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Middle right giftbox
          Positioned(
            top: size.height * 0.60,
            right: 30,
            child: Transform.rotate(
              angle: 50,
              child: CustomPaint(
                size: const Size(120, 130), // Star size
                painter: GiftBoxPainter(
                  boxColor: AppColors.light.withAlpha(188),
                  ribbonColor: AppColors.primary,
                ),
              ),
            ),
          ),

          // Bottom Car
          Positioned(
            top: size.height * 0.89,
            right: -32,
            child: CustomPaint(
              size: const Size(120, 120), // Star size
              painter: ToyCarPainter(
                bodyColor: AppColors.primary.withAlpha(218),
              ),
            ),
          ),

          // --- CONTENT LAYER (Must be last to sit ON TOP) ---
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
                            const SizedBox(height: 100),
                            // --- TOP SECTION: TITLE ---
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'PreLoved Toys',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Memories Never Go Out of Play',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // --- MIDDLE SPACER ---
                            // This takes up all available space.
                            // When keyboard opens, this shrinks, pulling the inputs UP.
                            const Spacer(),

                            // --- BOTTOM SECTION: INPUTS ---
                            TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter Mobile Number',
                                hintStyle: TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Icon(
                                  Icons.phone_android,
                                  color: AppColors.medium,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              height: 55,
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      onPressed: _handleSendOtp,
                                      child: const Text(
                                        'Send OTP',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              'By signing up, you agree to our Terms &\nConditions and Privacy Policy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }
}
