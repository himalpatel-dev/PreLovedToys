import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:preloved_toys/providers/favorite_provider.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:preloved_toys/widgets/product_item2.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_colors.dart';

/// Curved white background under the category carousel
class HeaderCurvePainter extends CustomPainter {
  final Color color;
  final double curveHeight;

  HeaderCurvePainter({required this.color, required this.curveHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final w = size.width;
    final h = curveHeight;

    path.moveTo(0, h * 0.55);
    path.quadraticBezierTo(w * 0.25, h, w * 0.5, h);
    path.quadraticBezierTo(w * 0.75, h, w, h * 0.55);
    path.lineTo(w, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.06), 8, true);
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
  int _selectedCategoryIndex = 0;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // page of groups-of-4 categories
  late final PageController _catPageController;
  double _pageOffset =
      0.0; // listens to pageController.page for smooth per-chip motion
  int _currentCategoryPage = 0;

  @override
  void initState() {
    super.initState();

    _catPageController = PageController(initialPage: 0);
    _catPageController.addListener(() {
      // page can be fractional while dragging
      setState(() {
        _pageOffset = _catPageController.hasClients
            ? (_catPageController.page ??
                  _catPageController.initialPage.toDouble())
            : 0.0;
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

  // basic icon mapping by category name (optional, just for visuals)
  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit')) return Icons.apple;
    if (n.contains('veg')) return Icons.grass;
    if (n.contains('meat')) return Icons.set_meal;
    if (n.contains('bread')) return Icons.bakery_dining;
    if (n.contains('milk')) return Icons.local_drink;
    if (n.contains('egg')) return Icons.egg;
    return Icons.shopping_bag_outlined;
  }

  // More pronounced curve values for 4-slot layout:
  double _slotTranslateYForIndexInPage(int slotIndex) {
    // slotIndex ∈ {0,1,2,3}
    switch (slotIndex) {
      case 0:
        return -26.0; // leftmost raises up
      case 1:
        return 12.0; // second drops down
      case 2:
        return 12.0; // third drops down
      case 3:
      default:
        return -26.0; // rightmost raises up
    }
  }

  // Computes per-chip horizontal parallax depending on how far page is dragged.
  // pageIndex = integer page (0..), pageOffset = fractional page reported by controller.
  // slotIndex 0..3: we stagger so chips slide with small offsets giving nice motion.
  double _chipParallax(
    int pageIndex,
    int slotIndex,
    double pageOffset,
    double availableWidth,
  ) {
    // how far current page is from the offset (0 = exactly aligned)
    final double pageDelta = pageIndex - pageOffset;
    // base slide distance is about 60% of availableWidth per page movement (tweakable)
    final double baseSlide = availableWidth * 0.6;
    // We apply slot-based multiplier to create stagger: outer slots move a bit more
    final multipliers = [0.9, 0.4, 0.4, 0.9];
    final m = multipliers[slotIndex.clamp(0, 3)];
    // final translation: negative means move left when pageDelta > 0 (swiping forward)
    return pageDelta * baseSlide * m;
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final categoryData = Provider.of<CategoryProvider>(context);
    final products = productData.products;
    final categories = categoryData.categories;

    // layout tuning
    const double carouselAreaHeight = 160;
    const double backgroundCurveHeight = 90;

    final screenWidth = MediaQuery.of(context).size.width;
    // available width inside the horizontal padding (20 left + 20 right)
    final double availableWidth = screenWidth - 40;

    // responsive chip size (clamped to avoid overflow on very small screens)
    final double baseChipWidth = (availableWidth / 5).clamp(48.0, 86.0);
    final double selectedChipWidth = baseChipWidth * 1.22;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // ---------- CATEGORY CAROUSEL (4 per page) ----------
                if (categoryData.isLoading)
                  const LinearProgressIndicator(minHeight: 2)
                else if (categories.isNotEmpty)
                  SizedBox(
                    height: carouselAreaHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // curved white background
                        Positioned.fill(
                          top: carouselAreaHeight - backgroundCurveHeight,
                          child: CustomPaint(
                            painter: HeaderCurvePainter(
                              color: Colors.white,
                              curveHeight: backgroundCurveHeight,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: carouselAreaHeight,
                          child: Column(
                            children: [
                              // PAGEVIEW: each page = up to 4 categories
                              Expanded(
                                child: PageView.builder(
                                  controller: _catPageController,
                                  itemCount: (categories.length / 4).ceil(),
                                  onPageChanged: (page) {
                                    setState(() {
                                      _currentCategoryPage = page;
                                    });
                                  },
                                  itemBuilder: (ctx, pageIndex) {
                                    final startIndex = pageIndex * 4;
                                    final endIndex = (startIndex + 4).clamp(
                                      0,
                                      categories.length,
                                    );
                                    final pageCats = categories.sublist(
                                      startIndex,
                                      endIndex,
                                    );

                                    // Row with 4 flexible slots. We'll apply per-chip transforms (translateX, translateY, scale)
                                    return Row(
                                      children: List.generate(4, (slot) {
                                        final int globalIndex =
                                            startIndex + slot;
                                        final hasCat = slot < pageCats.length;
                                        if (!hasCat) {
                                          return Expanded(child: SizedBox());
                                        }
                                        final cat = pageCats[slot];
                                        final isSelected =
                                            globalIndex ==
                                            _selectedCategoryIndex;

                                        // base Y curve for slot (deeper curve)
                                        final double translateY =
                                            _slotTranslateYForIndexInPage(slot);

                                        // parallax X translation according to page drag
                                        final double parallaxX = _chipParallax(
                                          pageIndex,
                                          slot,
                                          _pageOffset,
                                          availableWidth,
                                        );

                                        // scale small based on selection (keep consistent)
                                        final double scale = isSelected
                                            ? 1.0
                                            : 0.92;

                                        return Expanded(
                                          child: Center(
                                            child: Transform.translate(
                                              offset: Offset(
                                                parallaxX,
                                                translateY,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedCategoryIndex =
                                                        globalIndex;
                                                  });
                                                  // If tapped on a category not on the current page, jump to its page
                                                  final desiredPage =
                                                      (globalIndex / 4).floor();
                                                  if (desiredPage !=
                                                      pageIndex) {
                                                    _catPageController
                                                        .animateToPage(
                                                          desiredPage,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    360,
                                                              ),
                                                          curve: Curves.easeOut,
                                                        );
                                                  }
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeOut,
                                                  width: isSelected
                                                      ? selectedChipWidth
                                                      : baseChipWidth,
                                                  height: isSelected
                                                      ? selectedChipWidth
                                                      : baseChipWidth,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFF8E9B7,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(
                                                              isSelected
                                                                  ? 0.16
                                                                  : 0.06,
                                                            ),
                                                        blurRadius: isSelected
                                                            ? 14
                                                            : 8,
                                                        offset: const Offset(
                                                          0,
                                                          6,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Transform.scale(
                                                    scale: scale,
                                                    child: Center(
                                                      child: Icon(
                                                        _iconForCategory(
                                                          cat.name,
                                                        ),
                                                        size:
                                                            (isSelected
                                                                ? selectedChipWidth
                                                                : baseChipWidth) *
                                                            0.42,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 6),

                              // page indicators (1 dot per group-of-4)
                              SizedBox(
                                height: 10,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      (categories.length / 4).ceil(),
                                      (i) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: _currentCategoryPage == i
                                            ? 18
                                            : 8,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _currentCategoryPage == i
                                              ? AppColors.primary
                                              : Colors.grey.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 18),

                // ---------- PRODUCTS GRID ----------
                Expanded(
                  child: productData.isLoading
                      ? const Center(
                          child: BouncingDiceLoader(color: AppColors.primary),
                        )
                      : products.isEmpty
                      ? const Center(child: Text("No toys found!"))
                      : NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            if (notification.direction ==
                                ScrollDirection.reverse) {
                              widget.onScrollCallback(false);
                            } else if (notification.direction ==
                                ScrollDirection.forward) {
                              widget.onScrollCallback(true);
                            }
                            return true;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.60,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 25,
                                ),
                            itemBuilder: (ctx, index) {
                              return ProductItem2(product: products[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
