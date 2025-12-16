import 'package:flutter/material.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../providers/auth_provider.dart';
import 'subcategory_products_screen.dart';

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);

      catProvider
          .fetchCategories(isLoadFromDb: authProvider.isLoadDataFromDb)
          .then((_) {
            // 2. Once categories load, fetch subcategories for the *first* one
            if (catProvider.categories.isNotEmpty) {
              catProvider.fetchSubCategories(
                catProvider.categories[0].id,
                isLoadFromDb: authProvider.isLoadDataFromDb,
              );
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: BouncingDiceLoader(color: AppColors.primary),
            );
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          return Row(
            children: [
              // --- LEFT SIDEBAR (Main Categories) ---
              Container(
                width: 90,
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 50, top: 30),
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
                  padding: const EdgeInsets.only(top: 50, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
        // Get the auth flag
        final isLoadFromDb = Provider.of<AuthProvider>(
          context,
          listen: false,
        ).isLoadDataFromDb;
        provider.fetchSubCategories(category.id, isLoadFromDb: isLoadFromDb);
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
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Builder(
                          builder: (context) {
                            final imagePath = category.image ?? '';
                            if (imagePath.isEmpty) {
                              return const Icon(
                                Icons.category,
                                size: 20,
                                color: Colors.grey,
                              );
                            }

                            // Check if it is an asset (local) or network (url)
                            if (imagePath.startsWith('assets/')) {
                              return Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                    color: Colors.red,
                                  );
                                },
                              );
                            } else {
                              return Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) {
                                  return const Icon(
                                    Icons.category,
                                    size: 20,
                                    color: Colors.grey,
                                  );
                                },
                              );
                            }
                          },
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubcategoryProductsScreen(
              subcategoryId: subCat.id,
              subcategoryName: subCat.name,
            ),
          ),
        );
      },
      child: Column(
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
      ),
    );
  }
}
