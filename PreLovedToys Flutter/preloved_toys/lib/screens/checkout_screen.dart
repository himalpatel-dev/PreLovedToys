import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/order_success_screen.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/address_provider.dart';
import '../models/address_model.dart';
import '../models/product_model.dart';
import 'address_selection_screen.dart';
import '../providers/order_provider.dart';

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

    double totalAmount = cartProvider.totalRupees;

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
                  onPressed: () async {
                    // Navigate and wait for result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressSelectionScreen(
                          selectedId: _defaultAddress
                              ?.id, // Pass current ID to highlight it
                        ),
                      ),
                    );

                    // If user confirmed a selection, update UI
                    if (result != null && result is Address) {
                      setState(() {
                        _defaultAddress = result;
                      });
                    }
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
                    ),
                    child: const Center(
                      child: Icon(Icons.map, color: Colors.red, size: 30),
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
                                _defaultAddress!.addressType,
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
                  const NeverScrollableScrollPhysics(), // Important inside SingleChildScrollView
              shrinkWrap: true,
              itemCount: cartItems.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (ctx, i) {
                // Use LOCAL horizontal widget instead of ProductItem2
                return _buildCheckoutItem(cartItems[i].product);
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
                    child: const Icon(Icons.attach_money, color: Colors.green),
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

            const SizedBox(height: 100),
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
                onPressed: () async {
                  if (_defaultAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select an address first"),
                      ),
                    );
                    return;
                  }

                  try {
                    // Call the API with the selected address ID
                    await Provider.of<OrderProvider>(
                      context,
                      listen: false,
                    ).placeOrder(_defaultAddress!.id);

                    if (context.mounted) {
                      // Navigate to Success Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderSuccessScreen(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to place order: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Provider.of<OrderProvider>(context).isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Place Order",
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

  // --- NEW LOCAL WIDGET (Horizontal Layout) ---
  Widget _buildCheckoutItem(Product product) {
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Condition: ${product.condition}", // Using condition as detail
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Price
          Text(
            "\$${product.price.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
