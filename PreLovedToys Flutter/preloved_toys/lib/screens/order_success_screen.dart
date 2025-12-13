import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart'; // To go back to Home

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // --- 1. SUCCESS IMAGE ---
              Image.asset(
                'assets/images/cartsuccess.jpg',
                height: size.height * 0.3, // 30% of screen height
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 40),

              // --- 2. SUCCESS TEXT ---
              const Text(
                "Your order has been\nplaced successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Thank you for choosing us! Feel free to continue shopping and explore our wide range of products. Happy Shopping!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // --- 3. CONTINUE SHOPPING BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to MainScreen (Home) and remove all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue Shopping",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
