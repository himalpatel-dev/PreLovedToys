import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/my_listings_provider.dart';
import '../utils/app_colors.dart';
import '../models/product_model.dart';
import '../widgets/custom_loader.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<Offset> _hintAnimation;

  // Track selected tab index (0 = Selling, 1 = Sold)
  int _selectedTabIndex = 0;

  final Color _headerColor = AppColors.primary;

  @override
  void initState() {
    super.initState();

    _hintController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _hintAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.2, 0.0)).animate(
          CurvedAnimation(
            parent: _hintController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyListingsProvider>(
        context,
        listen: false,
      ).fetchMyListings().then((_) {
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
    final listingsData = Provider.of<MyListingsProvider>(context);
    final allListings = listingsData.listings;

    final activeListings = allListings
        .where((p) => p.status.toLowerCase() == 'active')
        .toList();
    final soldListings = allListings
        .where((p) => p.status.toLowerCase() == 'sold')
        .toList();

    final currentList = _selectedTabIndex == 0 ? activeListings : soldListings;
    final isEditable = _selectedTabIndex == 0;

    return Scaffold(
      backgroundColor: _headerColor,
      body: Column(
        children: [
          // --- Custom Header with Tabs ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
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
                            "My Listings",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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

                  const SizedBox(height: 12),

                  // Tabs row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton("Selling", 0),
                      const SizedBox(width: 12),
                      _buildTabButton("Sold", 1),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Curved sheet with listings ---
          Expanded(
            child: ClipPath(
              clipper: TopConvexClipper(),
              child: Container(
                color: const Color(0xFFF9F9F9),
                child: listingsData.isLoading
                    ? Container(
                        color: Colors.black.withAlpha(
                          120,
                        ), // Semi-transparent black background
                        child: const Center(
                          child: BouncingDiceLoader(color: AppColors.primary),
                        ),
                      )
                    : currentList.isEmpty
                    ? _buildEmptyState(isEditable)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 50,
                        ),
                        itemCount: currentList.length,
                        separatorBuilder: (ctx, i) =>
                            const SizedBox(height: 16),
                        itemBuilder: (ctx, index) {
                          final product = currentList[index];

                          if (isEditable) {
                            if (index == 0) {
                              return _buildAnimatedDismissibleItem(product);
                            }
                            return _buildDismissibleItem(product);
                          }

                          return _buildListingCard(product, isEditable: false);
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

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTabIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut, // Smoother animation curve
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          // Add a subtle shadow only when selected for depth
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            // Assuming AppColors.primary is defined, otherwise use Colors.blue
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
            fontFamily: 'Inter', // Suggesting a modern font
          ),
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isActiveTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActiveTab
                ? Icons.inventory_2_outlined
                : Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isActiveTab ? "No active listings" : "No sold items yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDismissibleItem(Product product) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
        ),
        SlideTransition(
          position: _hintAnimation,
          child: _buildDismissibleItem(product),
        ),
      ],
    );
  }

  Widget _buildDismissibleItem(Product product) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Listing?"),
            content: const Text(
              "Are you sure you want to remove this listing?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<MyListingsProvider>(
          context,
          listen: false,
        ).deleteListing(product.id);
      },
      child: _buildListingCard(product, isEditable: true),
    );
  }

  Widget _buildListingCard(Product product, {required bool isEditable}) {
    final imageUrl = product.images.isNotEmpty
        ? product.images[0]
        : 'https://via.placeholder.com/150';

    // Format date to show only YYYY-MM-DD
    final dateStr = product.updatedAt != null
        ? DateFormat('MMM dd, yyyy').format(product.updatedAt!)
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Edit coming soon!")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusConditionBgColor(product.condition),
                        borderRadius: BorderRadius.circular(6),
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
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Price",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
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
                                  color: AppColors.textDark,
                                ),
                              ),
                            const SizedBox(width: 2),
                            Text(
                              product.price.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Listed on",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
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
