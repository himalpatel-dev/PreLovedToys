import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/product_item.dart';
import '../utils/app_colors.dart';
import 'package:flutter/rendering.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final categoryData = Provider.of<CategoryProvider>(context);
    final products = productData.products;
    final categories = categoryData.categories;

    final double fullWidth = MediaQuery.of(context).size.width - 40;

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
                const SizedBox(height: 20),

                // --- 1. HEADER ---
                SizedBox(
                  height: 60,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // TITLE
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedOpacity(
                          opacity: _isSearchActive ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Text(
                            "Discover the Best",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),

                      // SEARCH BAR
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          clipBehavior: Clip.hardEdge,
                          width: _isSearchActive ? fullWidth : 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            // NO BORDER HERE
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              width: _isSearchActive ? fullWidth : 50,
                              height: 50,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icon
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSearchActive = true;
                                      });
                                      Future.delayed(
                                        const Duration(milliseconds: 100),
                                        () {
                                          _searchFocusNode.requestFocus();
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.transparent,
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // Input
                                  Expanded(
                                    child: _isSearchActive
                                        ? TextField(
                                            controller: _searchController,
                                            focusNode: _searchFocusNode,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: "Search for toys...",
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              // FORCE REMOVE ALL BORDERS
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                  // Close Button
                                  if (_isSearchActive)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isSearchActive = false;
                                          _searchController.clear();
                                          _searchFocusNode.unfocus();
                                        });
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.transparent,
                                        child: const Icon(
                                          Icons.close,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- 2. CATEGORIES ---
                const Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 15),

                if (categoryData.isLoading)
                  const LinearProgressIndicator(minHeight: 2)
                else if (categories.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, index) {
                        final cat = categories[index];
                        final isSelected = index == _selectedCategoryIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                            ),
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // --- 3. PRODUCT GRID ---
                Expanded(
                  child: productData.isLoading
                      ? const Center(child: CircularProgressIndicator())
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
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                ),
                            itemBuilder: (ctx, index) {
                              return ProductItem(product: products[index]);
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
