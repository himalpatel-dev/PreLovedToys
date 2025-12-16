import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';
import '../widgets/custom_loader.dart';

class SubcategoryProductsScreen extends StatefulWidget {
  final int subcategoryId;
  final String subcategoryName;

  const SubcategoryProductsScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  State<SubcategoryProductsScreen> createState() =>
      _SubcategoryProductsScreenState();
}

class _SubcategoryProductsScreenState extends State<SubcategoryProductsScreen> {
  final Color _headerColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProductsBySubcategory(widget.subcategoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Center(
                      child: Consumer<ProductProvider>(
                        builder: (context, provider, child) {
                          final text = provider.isLoading
                              ? widget.subcategoryName
                              : "${widget.subcategoryName} ( ${provider.products.length} )";

                          return Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // RIGHT: Invisible button (balance)
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

          // --- Curved sheet with products ---
          Expanded(
            child: ClipPath(
              clipper: TopConvexClipper(),
              child: Container(
                color: const Color(0xFFF9F9F9),
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    if (productProvider.isLoading) {
                      return Container(
                        color: Colors.black.withAlpha(120),
                        child: const Center(
                          child: BouncingDiceLoader(color: AppColors.primary),
                        ),
                      );
                    }

                    final products = productProvider.products;

                    if (products.isEmpty) {
                      return _buildEmptyState();
                    }

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          refreshTriggerPullDistance: 120.0,
                          refreshIndicatorExtent: 60.0,
                          onRefresh: () => productProvider
                              .fetchProductsBySubcategory(widget.subcategoryId),
                          builder:
                              (
                                context,
                                refreshState,
                                pulledExtent,
                                refreshTriggerPullDistance,
                                refreshIndicatorExtent,
                              ) {
                                final double percentage =
                                    (pulledExtent / refreshTriggerPullDistance)
                                        .clamp(0.0, 1.0);
                                final bool isArmed =
                                    refreshState == RefreshIndicatorMode.armed;
                                final bool isRefreshing =
                                    refreshState ==
                                    RefreshIndicatorMode.refresh;

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: pulledExtent / 2 - 15,
                                      child: Transform.scale(
                                        scale: isRefreshing ? 1.0 : percentage,
                                        child: AnimatedRotation(
                                          turns: isRefreshing
                                              ? 0.25 // Static angle during refresh if no controller
                                              : percentage,
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                          child: Icon(
                                            Icons.toys,
                                            // Change color when pulled far enough to indicate "release to refresh"
                                            color: isArmed || isRefreshing
                                                ? Colors.orange
                                                : AppColors.primary,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 50)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return ProductItem(product: products[index]);
                            }, childCount: products.length),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products available in ${widget.subcategoryName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Custom clipper that creates a centered upward arch (convex/hill)
class TopConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // The vertical height of the curve (how much it arches)
    double curveHeight = 40.0;

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
