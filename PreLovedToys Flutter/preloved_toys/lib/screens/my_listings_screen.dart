import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Ensure intl is added to pubspec.yaml
import '../providers/my_listings_provider.dart';
import '../utils/app_colors.dart';
import '../models/product_model.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyListingsProvider>(context, listen: false).fetchMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingsData = Provider.of<MyListingsProvider>(context);
    final listings = listingsData.listings;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          "My Listings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: listingsData.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : listings.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: listings.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (ctx, index) {
                return _buildListingCard(listings[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No listings yet",
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

  Widget _buildListingCard(Product product) {
    final imageUrl = product.images.isNotEmpty
        ? product.images[0]
        : 'https://via.placeholder.com/150';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded like image
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
          // --- 1. IMAGE (Left Side) ---
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

          // --- 2. DETAILS (Right Side) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Edit Icon Row
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
                    const SizedBox(width: 8),
                    // Edit Icon (Circular Grey Background)
                    Container(
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
                  ],
                ),

                const SizedBox(height: 8),

                // Badges Row (Status + Condition)
                Row(
                  children: [
                    // Status Badge (Red dot + text)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(product.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusDotColor(product.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.status.toUpperCase(), // e.g. SOLD
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusTextColor(product.status),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Condition Badge (Greenish/Grey)
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
                        product.condition, // e.g. Good
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusConditionTextColor(
                            product.condition,
                          ), // Dark Green Text
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Price + Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price
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
                                fontWeight: FontWeight.w900, // Extra Bold
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Listed Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Listed on",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMM d, yyyy').format(product.updatedAt),
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

  // --- COLOR HELPERS ---

  Color _getStatusBgColor(String status) {
    if (status.toLowerCase() == 'sold') {
      return const Color(0xFFFFEBEE); // Light Red
    }
    if (status.toLowerCase() == 'active') {
      return const Color(0xFFE3F2FD); // Light Blue
    }
    return Colors.grey[100]!;
  }

  Color _getStatusDotColor(String status) {
    if (status.toLowerCase() == 'sold') return Colors.red;
    if (status.toLowerCase() == 'active') return Colors.blue;
    return Colors.grey;
  }

  Color _getStatusTextColor(String status) {
    if (status.toLowerCase() == 'sold') return Colors.red[800]!;
    if (status.toLowerCase() == 'active') return Colors.blue[800]!;
    return Colors.grey[800]!;
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
