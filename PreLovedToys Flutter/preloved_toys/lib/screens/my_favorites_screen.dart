import 'package:flutter/material.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:preloved_toys/widgets/product_item2.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../utils/app_colors.dart';

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  final Color _headerColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favData = Provider.of<FavoriteProvider>(context);
    final favorites = favData.favorites;

    return Scaffold(
      backgroundColor: _headerColor,
      body: Column(
        children: [
          // --- Custom Header ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Back Button
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),

                  // CENTER: Title
                  const Expanded(
                    child: Center(
                      child: Text(
                        "My Favorites",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // RIGHT: Invisible button to balance the row
                  Opacity(
                    opacity: 0,
                    child: _buildCircleButton(
                      icon: Icons.more_horiz,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- THE CURVED SHEET (ClipPath + TopConvexClipper) ---
          Expanded(
            child: ClipPath(
              clipper: TopConvexClipper(),
              child: Container(
                color: const Color(0xFFF9F9F9),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: favData.isLoading
                          ? const Center(
                              child: BouncingDiceLoader(
                                color: AppColors.primary,
                              ),
                            )
                          : favorites.isEmpty
                          ? _buildEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                20,
                              ),
                              itemCount: favorites.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                  ),
                              itemBuilder: (ctx, index) {
                                // favorites[index] is assumed to have `.product`
                                return ProductItem2(
                                  product: favorites[index].product,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No favorites yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Save items you like to find them later!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper that creates a centered upward arch (convex/hill)
/// matching the 'Product Details' style used in MyOrdersScreen.
class TopConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // The vertical height of the curve (how much it arches)
    double curveHeight = 40.0;

    // 1. Start at the left edge, down by curveHeight
    path.moveTo(0, curveHeight);

    // 2. Draw a single smooth quadratic bezier curve
    path.quadraticBezierTo(size.width / 2, 0, size.width, curveHeight);

    // 3. Line down to the bottom-right corner
    path.lineTo(size.width, size.height);

    // 4. Line to the bottom-left corner
    path.lineTo(0, size.height);

    // 5. Close the path back to the start
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
