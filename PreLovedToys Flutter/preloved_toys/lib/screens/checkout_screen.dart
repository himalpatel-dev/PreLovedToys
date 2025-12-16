import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/order_success_screen.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
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
    try {
      final addr = await addrProvider.fetchDefaultAddress();
      if (mounted) {
        setState(() {
          _defaultAddress = addr;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
        // Optionally show error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load address: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    double totalAmount = cartProvider.totalRupees;

    // OrderProvider used to show full-screen loader when placing order
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      // Use a Stack so we can display a full-screen modal loader on top
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // --------------------- CURVED HEADER ---------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),

                      const Text(
                        "Payment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 35), // balance spacing
                    ],
                  ),
                ),

                // --------------------- CURVED WHITE SHEET ---------------------
                Expanded(
                  child: ClipPath(
                    clipper: TopConvexClipper(),
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- 1. ADDRESS SECTION ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Address",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddressSelectionScreen(
                                              selectedId: _defaultAddress?.id,
                                            ),
                                      ),
                                    );

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
                                  Container(
                                    width: 100,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(15),
                                          ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.map,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  Expanded(
                                    child: _isLoadingAddress
                                        // <-- your linear loader inside the address area
                                        ? const LinearProgressIndicator()
                                        : _defaultAddress == null
                                        ? const Text("No Default Address Set")
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartItems.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 15),
                              itemBuilder: (ctx, i) =>
                                  _buildCheckoutItem(cartItems[i].product),
                            ),

                            const SizedBox(height: 25),

                            // --- 3. PAYMENT METHOD ---
                            const Text(
                              "Payment Method",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                      Icons.attach_money,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  const Expanded(
                                    child: Text(
                                      "Cash on Delivery",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --------------------- BOTTOM SHEET ---------------------
                _buildBottomBar(totalAmount),
              ],
            ),
          ),

          // --------------------- FULL-SCREEN LOADER ---------------------
          // Driven by OrderProvider.isLoading so it appears while placing order.
          if (orderProvider.isLoading)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false, // block touches
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: BouncingDiceLoader(color: AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------- BOTTOM TOTAL BAR -------------------
  Widget _buildBottomBar(double totalAmount) {
    return Container(
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
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
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
    );
  }

  // ------------------- PLACE ORDER LOGIC -------------------
  Future<void> _placeOrder() async {
    if (_defaultAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an address first")),
      );
      return;
    }

    try {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).placeOrder(_defaultAddress!.id);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
      }
    }
  }

  // ------------------- PRODUCT ROW WIDGET -------------------
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
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),

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
                  "Condition: ${product.condition}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          Text(
            "\$${product.price.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ------------------- CURVE CLIPPER -------------------
class TopConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curveHeight = 40.0;
    var path = Path();
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
