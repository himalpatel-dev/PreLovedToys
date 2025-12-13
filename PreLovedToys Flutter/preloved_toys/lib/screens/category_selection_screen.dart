import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int _selectedIndex = 0; // Tracks which index in the list is selected

  @override
  void initState() {
    super.initState();
    // 1. Fetch Categories on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      provider.fetchCategories().then((_) {
        // 2. Once categories load, fetch subcategories for the *first* one automatically
        if (provider.categories.isNotEmpty) {
          provider.fetchSubCategories(provider.categories[0].id);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "All Categories",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          return Row(
            children: [
              // --- LEFT SIDEBAR (Main Categories) ---
              Container(
                width: 90,
                color: const Color(0xFFF0F2F5), // Light grey background
                child: ListView.builder(
                  itemCount: provider.categories.length,
                  itemBuilder: (ctx, index) {
                    final cat = provider.categories[index];
                    return _buildSideBarItem(cat, index, provider);
                  },
                ),
              ),

              // --- RIGHT SIDE (Subcategories) ---
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Selected Category Name
                      Text(
                        provider.categories[_selectedIndex].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid Content
                      Expanded(
                        child: provider.isSubLoading
                            ? const Center(child: CircularProgressIndicator())
                            : provider.subCategories.isEmpty
                            ? const Center(
                                child: Text("No subcategories found"),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: provider.subCategories.length,
                                itemBuilder: (ctx, index) {
                                  return _buildSubCategoryItem(
                                    provider.subCategories[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Sidebar Item Widget ---
  Widget _buildSideBarItem(
    Category category,
    int index,
    CategoryProvider provider,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // Fetch subcategories for the clicked category
        provider.fetchSubCategories(category.id);
      },
      child: Container(
        color: isSelected ? Colors.white : Colors.transparent,
        child: Row(
          children: [
            // Colored Indicator
            Container(
              width: 5,
              height: 80,
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon/Image
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          category.image ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                            Icons.category,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  // --- Subcategory Item Widget ---
  Widget _buildSubCategoryItem(SubCategory subCat) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6F9),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.network(
              subCat.image,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subCat.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textDark),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
