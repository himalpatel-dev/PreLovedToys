import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/cart_screen.dart';
import 'package:preloved_toys/utils/app_colors.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math; // Import math for rotation calculations
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final Product? previewProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.previewProduct,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;

  // 1. GLOBAL KEYS
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _product = widget.previewProduct;
    _fetchFullDetails();
  }

  void _fetchFullDetails() async {
    try {
      final fullData = await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProductDetails(widget.productId);

      if (mounted) {
        setState(() {
          _product = fullData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------
  // 2. NEW "VELOCITY STRETCH / SUCK" ANIMATION
  // ------------------------------------------------------------
  // ------------------------------------------------------------
  // 3. PARABOLIC THROW ANIMATION (Classic E-commerce Style)
  // ------------------------------------------------------------
  void _runAddToCartAnimation(String imageUrl) {
    // 1. Get RenderBoxes to find positions
    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox =
        _cartKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox == null || cartBox == null) return;

    // 2. Start Position (Center of the Product Image)
    final Offset startPos = imageBox.localToGlobal(Offset.zero);
    final Size startSize = imageBox.size;
    final Offset p0 = Offset(
      startPos.dx + startSize.width / 2,
      startPos.dy + startSize.height / 2,
    );

    // 3. End Position (Center of the Cart Icon)
    final Offset endPos = cartBox.localToGlobal(Offset.zero);
    final Size endSize = cartBox.size;
    final Offset p2 = Offset(
      endPos.dx + endSize.width / 2,
      endPos.dy + endSize.height / 2,
    );

    // 4. Control Point (The peak of the arc)
    // We go halfway between X values, and significantly higher than the start Y
    // to create a nice upward curve (Arc).
    final double peakHeight = 150.0; // How high it throws
    final Offset p1 = Offset(
      (p0.dx + p2.dx) / 2,
      math.min(p0.dy, p2.dy) - peakHeight,
    );

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800), // Smooth flight
          curve: Curves.easeInOutCubic, // Starts slow, speeds up into cart
          builder: (context, value, child) {
            // BEZIER CURVE FORMULA:
            // B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
            final double t = value;
            final double oneMinusT = 1.0 - t;

            final double currentX =
                (oneMinusT * oneMinusT * p0.dx) +
                (2 * oneMinusT * t * p1.dx) +
                (t * t * p2.dx);

            final double currentY =
                (oneMinusT * oneMinusT * p0.dy) +
                (2 * oneMinusT * t * p1.dy) +
                (t * t * p2.dy);

            // SCALE: Shrink from full size to tiny dot
            // We clamp it so it doesn't disappear completely until the very end
            final double currentScale = (1.0 - t).clamp(0.1, 1.0);

            // OPACITY: Fade out slightly at the very end
            final double currentOpacity = (t > 0.9) ? (1.0 - t) * 10 : 1.0;

            // ROTATION: Spin it slightly as it flies
            final double currentRotation = t * 2 * math.pi;

            return Positioned(
              left: currentX - (startSize.width / 2),
              top: currentY - (startSize.height / 2),
              child: Opacity(
                opacity: currentOpacity,
                child: Transform.rotate(
                  angle: currentRotation, // Optional: Makes it spin
                  child: Transform.scale(
                    scale: currentScale,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: startSize.width,
                      height: startSize.height,
                      // Use a Circular Avatar or Rounded Rect to make the flying object look neat
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover, // Keeps image looking normal!
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            overlayEntry?.remove();
          },
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_product == null && _isLoading) {
      return const Scaffold(
        body: Center(child: BouncingDiceLoader(color: AppColors.primary)),
      );
    }
    final product = _product!;
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Expanded(
                    child: Center(
                      child: Text(
                        "Product Detail",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartScreen(),
                                ),
                              );
                            },
                            child: Container(
                              key: _cartKey, // 3. Target Key
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  if (cart.items.isNotEmpty)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 8,
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Content ---
            Expanded(
              child: ClipPath(
                clipper: TopConvexClipper(),
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        Center(
                          child: Container(
                            key: _imageKey, // 4. Source Key
                            height: MediaQuery.of(context).size.height * 0.45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.fill,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // ... Rest of your UI ...
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Consumer<FavoriteProvider>(
                              builder: (context, favProvider, child) {
                                final isFav = favProvider.isFavorite(
                                  product.id,
                                );
                                return GestureDetector(
                                  onTap: () =>
                                      favProvider.toggleFavorite(product.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                      size: 22,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text(
                              "4.8",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "(320 Review)",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          product.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Seller Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  (product.sellerName ?? "S")[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.sellerName ?? "Unknown Seller",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Verified Seller",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  "Follow",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Specifications",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (product.condition.isNotEmpty)
                              _buildSpecChip("Condition", product.condition),
                            if (product.color != null)
                              _buildSpecChip("Color", product.color!),
                            if (product.material != null)
                              _buildSpecChip("Material", product.material!),
                            if (product.ageGroup != null)
                              _buildSpecChip("Age", product.ageGroup!),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --- Bottom Action Bar ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Row(
                          children: [
                            if (product.isPoints)
                              const Icon(
                                Icons.stars,
                                size: 24,
                                color: Colors.amber,
                              ),
                            if (!product.isPoints)
                              const Text(
                                '\$',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.textDark,
                                ),
                              ),
                            const SizedBox(width: 4),
                            Text(
                              product.price.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                      width: 160,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // 5. Trigger Animation
                          _runAddToCartAnimation(imageUrl);

                          // Capture context before async operations
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );

                          try {
                            await Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addToCart(product.id);

                            // Delay snackbar slightly to let animation play
                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Added to Cart Successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            );
                          } catch (e) {
                            String msg = e.toString().replaceAll(
                              'Exception: ',
                              '',
                            );
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

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
