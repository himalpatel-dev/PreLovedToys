import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../models/address_model.dart';
import '../widgets/product_item2.dart'; // Using the horizontal card widget

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? _defaultAddress;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final addrProvider = Provider.of<AddressProvider>(context, listen: false);
    final addr = await addrProvider.fetchDefaultAddress();
    if (mounted) {
      setState(() {
        _defaultAddress = addr;
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    // Calculate total from cart items directly
    double totalAmount = cartProvider.totalRupees;
    // Note: If you have points logic mixed, you might need a getter for mixed total or just rupees

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ADDRESS SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Address",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to Address List to change
                  },
                  child: const Text(
                    "Edit",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  // Fake Map Image
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(15),
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://via.placeholder.com/150",
                        ), // Replace with a map snippet asset
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.location_on, color: Colors.red),
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Address Text
                  Expanded(
                    child: _isLoadingAddress
                        ? const LinearProgressIndicator()
                        : _defaultAddress == null
                        ? const Text("No Default Address Set")
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _defaultAddress!.addressType, // e.g. "Home"
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _defaultAddress!.fullAddress,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),

            // --- 2. PRODUCTS LIST ---
            Text(
              "Products (${cartItems.length})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            ListView.separated(
              physics:
                  const NeverScrollableScrollPhysics(), // Scroll entire page instead
              shrinkWrap: true,
              itemCount: cartItems.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (ctx, i) {
                // We use ProductItem2 (horizontal card) but disable qty controls for checkout view
                return ProductItem2(product: cartItems[i].product);
              },
            ),

            const SizedBox(height: 25),

            // --- 3. PAYMENT METHOD ---
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.money,
                      color: Colors.green,
                    ), // COD Icon
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "Cash on Delivery",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),

      // --- 4. BOTTOM CHECKOUT BAR ---
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total amount",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  "\$${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Call Place Order API here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Order Placed Successfully!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Checkout Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
