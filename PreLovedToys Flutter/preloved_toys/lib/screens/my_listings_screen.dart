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

  // Track selected tab index (0 = Active, 1 = Sold)
  int _selectedTabIndex = 0;

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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        // --- CUSTOM TITLE ROW ---
        title: Row(
          children: [
            const Text(
              "My Listings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(), // Pushes the toggle to the right
            // Toggle Switch
            Container(
              height: 36, // Smaller height to fit in AppBar
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabButton("Selling", 0),
                  const SizedBox(width: 2),
                  _buildTabButton("Sold", 1),
                ],
              ),
            ),
          ],
        ),
      ),
      body: listingsData.isLoading
          ? const Center(child: BouncingDiceLoader(color: AppColors.primary))
          : _buildList(currentList, isEditable: isEditable),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Product> items, {required bool isEditable}) {
    if (items.isEmpty) return _buildEmptyState(isEditable);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: items.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
      itemBuilder: (ctx, index) {
        final product = items[index];

        if (isEditable) {
          if (index == 0) {
            return _buildAnimatedDismissibleItem(product);
          }
          return _buildDismissibleItem(product);
        }

        return _buildListingCard(product, isEditable: false);
      },
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

    final dateStr = product.updatedAt;

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
                          dateStr.toString(),
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
