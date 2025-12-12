import 'package:flutter/material.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import '../models/cart_model.dart';
import 'checkout_screen.dart'; // Import Checkout Screen

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context);
    final items = cartData.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9F9),
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: Container(),
      ),
      body: cartData.isLoading
          ? const Center(child: BouncingDiceLoader(color: AppColors.primary))
          : items.isEmpty
          // --- 1. SHOW EMPTY STATE IF NO ITEMS ---
          ? _buildEmptyState()
          // --- 2. SHOW LIST & CHECKOUT IF ITEMS EXIST ---
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 20),
                    itemBuilder: (ctx, index) {
                      return _buildCartItem(items[index], index, cartData);
                    },
                  ),
                ),

                // Only show Checkout when items exist
                _buildBottomCheckout(cartData),

                // Bottom Nav Spacer
                const SizedBox(height: 90),
              ],
            ),
    );
  }

  // --- EMPTY STATE WIDGET ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined, // Big Logo
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "No items in your cart",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Start adding some items!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index, CartProvider provider) {
    final product = item.product;
    final imageUrl = product.images.isNotEmpty
        ? product.images[0]
        : 'https://via.placeholder.com/150';

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.removeFromCart(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Condition Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusConditionBgColor(product.condition),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.condition,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusConditionTextColor(product.condition),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    children: [
                      if (product.isPoints)
                        const Icon(Icons.stars, size: 16, color: Colors.amber),
                      if (!product.isPoints)
                        const Text(
                          '\$',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(width: 2),
                      Text(
                        product.price.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCheckout(CartProvider cartData) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Total Amount Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total amount",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    if (cartData.totalRupees > 0)
                      Text(
                        "\$${cartData.totalRupees.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),

                    if (cartData.totalRupees > 0 && cartData.totalPoints > 0)
                      const SizedBox(width: 8),

                    if (cartData.totalPoints > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            size: 20,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "${cartData.totalPoints}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
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
                  "Checkout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COLORS ---
  Color _getStatusConditionBgColor(String status) {
    if (status.toLowerCase() == 'good') return Colors.yellow[100]!;
    if (status.toLowerCase() == 'new') return Colors.blue[100]!;
    if (status.toLowerCase() == 'like new') return Colors.green[100]!;
    if (status.toLowerCase() == 'fair') return Colors.orange[100]!;
    return Colors.grey[100]!;
  }

  Color _getStatusConditionTextColor(String status) {
    if (status.toLowerCase() == 'good') return Colors.yellow[700]!;
    if (status.toLowerCase() == 'new') return Colors.blue[800]!;
    if (status.toLowerCase() == 'like new') return Colors.green[800]!;
    if (status.toLowerCase() == 'fair') return Colors.orange[800]!;
    return Colors.grey[800]!;
  }
}
