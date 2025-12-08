import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
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
              "Welcome to PreLoved. By accessing or using the PreLoved mobile application or website, you agree to comply with and be bound by these Terms & Conditions. If you do not agree, please do not use our services.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("About the Platform"),
            const Text(
              "PreLoved is a marketplace that connects buyers and sellers for the resale of pre-owned toys. PreLoved does not manufacture, own, or directly sell the toys unless clearly stated.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("User Eligibility"),
            const Text(
              "You must be at least 18 years old to create an account. By registering, you confirm that all information provided is accurate and truthful.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("User Responsibilities"),
            const Text(
              "You agree not to:",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            _buildBulletPoint("List illegal, unsafe, or prohibited items"),
            _buildBulletPoint("Misrepresent product condition or pricing"),
            _buildBulletPoint("Use abusive, fraudulent, or harmful behavior"),
            _buildBulletPoint("Violate any applicable laws"),

            _buildSectionTitle("Listings & Transactions"),
            const Text(
              "Sellers are responsible for the accuracy of listings. Buyers must review all details before purchasing. PreLoved is not responsible for disputes but may assist in resolution.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Payments"),
            const Text(
              "All payments must be made through approved payment methods on the platform. PreLoved is not responsible for payment failures caused by third-party providers.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Returns & Refunds"),
            const Text(
              "Return and refund policies may vary based on seller terms. PreLoved may provide mediation support but is not obligated to issue refunds.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Account Termination"),
            const Text(
              "We reserve the right to suspend or permanently terminate any account found violating our policies.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Intellectual Property"),
            const Text(
              "All content, branding, logos, and software belong to PreLoved and may not be copied or reused without permission.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Limitation of Liability"),
            const Text(
              "PreLoved is not liable for indirect losses, damages, misuse of products, or disputes between users.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Changes to Terms"),
            const Text(
              "We may update these Terms at any time. Continued use of the platform means acceptance of the latest version.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),

            _buildSectionTitle("Contact Information"),
            const Text(
              "For support: hnp.2792@gmail.com",
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
                "By using PreLoved, you agree to these Terms & Conditions.",
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
