import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
            const Text("You may:", style: TextStyle(fontSize: 16, height: 1.5)),
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
}
