import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:preloved_toys/providers/favorite_provider.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:preloved_toys/widgets/product_item2.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_colors.dart';

// ... (Keep your HeaderCurvePainter class exactly as it is) ...
class HeaderCurvePainter extends CustomPainter {
  final Color color;
  final double curveHeight;

  HeaderCurvePainter({required this.color, required this.curveHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = curveHeight;

    path.moveTo(0, 0);
    path.lineTo(0, h * .5);
    path.quadraticBezierTo(w * 0.18, h * 0.95, w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.82, h * 0.95, w, h * 0.35);
    path.lineTo(w, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  final Function(bool isVisible) onScrollCallback;
  const HomeScreen({super.key, required this.onScrollCallback});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final PageController _catPageController;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _catPageController = PageController(viewportFraction: 0.25, initialPage: 0);
    _catPageController.addListener(() {
      setState(() {
        _currentPageValue = _catPageController.page ?? 0.0;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _catPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final categoryData = Provider.of<CategoryProvider>(context);
    final products = productData.products;
    final categories = categoryData.categories;

    return Scaffold(
      primary: false,
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          if (_isSearchActive) {
            setState(() {
              _isSearchActive = false;
              _searchFocusNode.unfocus();
              _searchController.clear();
            });
          }
        },
        // WRAPPER: Handles scroll detection to hide/show bottom bar
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              widget.onScrollCallback(false); // Hide bottom bar
            } else if (notification.direction == ScrollDirection.forward) {
              widget.onScrollCallback(true); // Show bottom bar
            }
            return true;
          },
          // CORE CHANGE: CustomScrollView allows mixed content types to scroll together
          child: CustomScrollView(
            //    physics: const BouncingScrollPhysics(),
            physics: const ClampingScrollPhysics(),
            slivers: [
              // 1. THE HEADER (Scrolls away now)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: HeaderCurvePainter(
                            color: AppColors.primary,
                            curveHeight: 70,
                          ),
                        ),
                      ),
                      if (categoryData.isLoading)
                        const Center(
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      else if (categories.isNotEmpty)
                        PageView.builder(
                          controller: _catPageController,
                          itemCount: categories.length,
                          physics: const ClampingScrollPhysics(),
                          padEnds: false,
                          itemBuilder: (context, index) {
                            double itemWidth = 0.25;
                            double itemCenterPos =
                                (index - _currentPageValue) * itemWidth +
                                (itemWidth / 2);
                            double distFromCenter = itemCenterPos - 0.5;
                            double dy =
                                -200 * (distFromCenter * distFromCenter);
                            dy = dy.clamp(-60.0, 0.0);

                            final cat = categories[index];

                            return Transform.translate(
                              offset: Offset(0, dy + 0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {});
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8E9B7),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                      child: Image.network(
                                        cat.image!,
                                        height: 28,
                                        width: 28,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.category,
                                                size: 28,
                                                color: AppColors.primary,
                                              );
                                            },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // 2. THE PRODUCT GRID
              if (productData.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: BouncingDiceLoader(color: AppColors.primary),
                  ),
                )
              else if (products.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text("No toys found!")),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.60,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 25,
                        ),
                    delegate: SliverChildBuilderDelegate((ctx, index) {
                      return ProductItem2(product: products[index]);
                    }, childCount: products.length),
                  ),
                ),

              // Add a little bottom padding so the last item isn't behind the nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}
