import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart'; // To go back to Home
import 'my_orders_screen.dart'; // We will create this or you can link to Profile

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
                'images/cartsuccess.jpg',
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
                    backgroundColor: Colors.black,
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

              const SizedBox(height: 20),

              // --- 4. GO TO ORDERS BUTTON ---
              TextButton(
                onPressed: () {
                  // Navigate to My Orders Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Go to Orders",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .grey, // Grey color as typical for secondary actions
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Bottom Indicator (Visual Line from your image design)
              Container(
                width: 130,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
