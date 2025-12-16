import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color headerColor = AppColors.primary;

    return Scaffold(
      backgroundColor: headerColor,
      body: Column(
        children: [
          // --- Custom Header (safe area) ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Invisible to balance title
                  Opacity(
                    opacity: 0,
                    child: _buildCircleButton(
                      icon: Icons.more_horiz,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Curved White Sheet ---
          Expanded(
            child: ClipPath(
              clipper: TopConvexClipper(),
              child: Container(
                color: const Color(0xFFF9F9F9),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 54, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PreLoved respects your privacy and is committed to protecting your personal information.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),

                      _buildSectionTitle("Information We Collect"),
                      const Text(
                        "We may collect:",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      _buildBulletPoint("Name, phone number, email address"),
                      _buildBulletPoint("Shipping address (for deliveries)"),
                      _buildBulletPoint("Login credentials"),
                      _buildBulletPoint("Usage data and device information"),

                      _buildSectionTitle("How We Use Your Information"),
                      const Text(
                        "Your data is used to:",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      _buildBulletPoint("Create and manage your account"),
                      _buildBulletPoint("Process orders and payments"),
                      _buildBulletPoint("Provide customer support"),
                      _buildBulletPoint("Improve our services"),
                      _buildBulletPoint("Send important notifications"),

                      _buildSectionTitle("Data Protection"),
                      const Text(
                        "We implement appropriate security measures to protect your personal data from unauthorized access or misuse.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),

                      _buildSectionTitle("Data Sharing"),
                      const Text(
                        "We do not sell your personal data. Information may only be shared with:",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),
                      _buildBulletPoint("Payment gateways"),
                      _buildBulletPoint("Delivery partners"),
                      _buildBulletPoint("Legal authorities if required by law"),

                      _buildSectionTitle("Cookies & Tracking"),
                      const Text(
                        "We may use cookies and analytics tools to improve user experience and app performance.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),

                      _buildSectionTitle("Children's Privacy"),
                      const Text(
                        "PreLoved services are intended for parents/guardians. We do not knowingly collect personal data from children under 13.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),

                      _buildSectionTitle("Your Rights"),
                      const Text(
                        "You may:",
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      _buildBulletPoint("Access your data"),
                      _buildBulletPoint("Request corrections"),
                      _buildBulletPoint("Request deletion of your account"),

                      _buildSectionTitle("Policy Updates"),
                      const Text(
                        "This policy may be updated at any time. Continued use confirms acceptance.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),

                      _buildSectionTitle("Contact Us"),
                      const Text(
                        "For privacy concerns: hnp.2792@gmail.com",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Center(
                        child: Text(
                          "By using PreLoved, you agree to this Privacy Policy.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

/// Custom clipper that creates a centered upward arch (convex/hill)
class TopConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // The vertical height of the curve (how much it arches)
    double curveHeight = 40.0;

    path.moveTo(0, curveHeight);
    path.quadraticBezierTo(size.width / 2, 0, size.width, curveHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
