import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/checkout_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import '../models/cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<Offset> _hintAnimation;

  @override
  void initState() {
    super.initState();

    // 1. SETUP HINT ANIMATION (Slide Left)
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _hintAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.2, 0.0), // Move Left
        ).animate(
          CurvedAnimation(
            parent: _hintController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

    // 2. FETCH DATA & PLAY HINT
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart().then((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _hintController.forward().then((_) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) _hintController.reverse();
              });
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context);
    final items = cartData.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        // Clean Title, No Actions
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9F9),
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: cartData.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // --- CART LIST ---
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text("Your cart is empty"))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 20),
                          itemBuilder: (ctx, index) {
                            final item = items[index];

                            // Apply Hint Animation to FIRST item only
                            if (index == 0) {
                              return _buildAnimatedDismissibleItem(item);
                            }
                            return _buildDismissibleItem(item);
                          },
                        ),
                ),

                // --- BOTTOM CHECKOUT SECTION (FIXED WHITE BACKGROUND) ---
                _buildBottomCheckout(cartData),
              ],
            ),
    );
  }

  // --- ANIMATED WRAPPER (For Hint) ---
  Widget _buildAnimatedDismissibleItem(CartItem item) {
    return Stack(
      children: [
        Positioned.fill(child: _buildDeleteBackground()),
        SlideTransition(
          position: _hintAnimation,
          child: _buildDismissibleItem(item),
        ),
      ],
    );
  }

  // --- DISMISSIBLE ITEM (Swipe Logic) ---
  Widget _buildDismissibleItem(CartItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart, // Swipe Right -> Left
      background: _buildDeleteBackground(),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Remove Item?"),
            content: const Text(
              "Are you sure you want to remove this item from your cart?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Remove",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).removeFromCart(item.id);
      },
      child: _buildCartItem(item),
    );
  }

  // Helper for Red Background
  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }

  // --- CART CARD DESIGN ---
  Widget _buildCartItem(CartItem item) {
    final product = item.product;
    final imageUrl = product.images.isNotEmpty
        ? product.images[0]
        : 'https://via.placeholder.com/150';

    return Container(
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Condition Chip & Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Condition Chip (Replaced Qty)
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
                          color: _getStatusConditionTextColor(
                            product.condition,
                          ),
                        ),
                      ),
                    ),

                    // Price
                    Row(
                      children: [
                        if (product.isPoints)
                          const Icon(
                            Icons.stars,
                            size: 18,
                            color: Colors.amber,
                          ),
                        if (!product.isPoints)
                          const Text(
                            '\$',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(width: 4),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(CartProvider cartData) {
    return Container(
      // CRITICAL FIX: Make this container WHITE and extend padding to bottom
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
                    // Rupees
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

                    // Points
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

            // --- SPACER FOR BOTTOM NAV ---
            // This ensures the white background continues behind the transparent nav bar
            const SizedBox(height: 85),
          ],
        ),
      ),
    );
  }

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
