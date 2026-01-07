import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/master_data_provider.dart';
import '../utils/app_colors.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String? _title;
  String? _description;
  double? _price;
  bool _isPoints = true;
  String? _condition; // e.g. "Good", "New"
  int? _categoryId;
  int? _subCategoryId;
  int? _ageGroupId;
  int? _genderId;
  int? _colorId;
  int? _materialId;

  // _canSellCash and _eligibilityMessage are now accessed via Provider

  final List<String> _imageUrls = []; // Store image URLs (Mocking for now)

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    // Categories and MasterData are now fetched in MainScreen
  }

  // _checkEligibility removed as we use Provider state directly

  // Handle Category Change to fetch Subcategories
  void _onCategoryChanged(int? newId) {
    if (newId != _categoryId) {
      setState(() {
        _categoryId = newId;
        _subCategoryId = null; // Reset subcategory
      });
      if (newId != null) {
        Provider.of<CategoryProvider>(
          context,
          listen: false,
        ).fetchSubCategories(newId);
      }
    }
  }

  // Mock Image Picker
  void _pickImage() {
    setState(() {
      // Add a dummy image for demonstration
      _imageUrls.add(
        'https://picsum.photos/200?random=${DateTime.now().millisecondsSinceEpoch}',
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mock Image Added')));
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    // Construct the payload matching backend expectations
    final Map<String, dynamic> payload = {
      'title': _title,
      'description': _description,
      'price': _price,
      'isPoints': _isPoints,
      'condition': _condition,
      'categoryId': _categoryId,
      'subCategoryId': _subCategoryId,
      'ageGroupId': _ageGroupId,
      'genderId': _genderId,
      'colorId': _colorId,
      'materialId': _materialId,
      'images': _imageUrls,
    };

    try {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).addProduct(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product listed successfully!')),
        );
        // Reset form or navigate away
        _formKey.currentState!.reset();
        setState(() {
          _imageUrls.clear();
          _categoryId = null;
          _subCategoryId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        // Show error (e.g. "Must complete at least 3 point-based sales")
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString().replaceAll("Exception:", "").trim()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CategoryProvider>(context);
    final masterProvider = Provider.of<MasterDataProvider>(context);
    final prodProvider = Provider.of<ProductProvider>(context);

    // Access eligibility from Provider
    final canSellCash = prodProvider.canSellCash;
    final eligibilityMessage = prodProvider.eligibilityMessage;

    // Ensure state consistency: if cash is selected but not allowed, switch to points
    // We do this in build to react to provider changes, but be careful of setState during build.
    // A better way is to handle this logic when the user TRIES to switch, or use a post-frame callback.
    // For now, we just use the provider values for display and logic.

    // Modern Input Decoration
    InputDecoration inputDeco(String label, {IconData? icon, String? hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 22)
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      physics: const ClampingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            // Eligibility Warning
            if (eligibilityMessage != null && !canSellCash)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5), // Soft Orange
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE0B2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selling Eligibility",
                            style: TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            eligibilityMessage,
                            style: const TextStyle(
                              color: Color(0xFFEF6C00),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // --- PHOTOS SECTION ---
            Text(
              "Photos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 130,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _imageUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_a_photo_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Add Photo",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final url = _imageUrls[index - 1];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeImage(index - 1),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // --- BASIC INFO ---
            _buildSectionHeader("Item Details"),
            _buildCard(
              child: Column(
                children: [
                  TextFormField(
                    decoration: inputDeco(
                      "Product Title",
                      hint: "e.g. Lego Star Wars Set",
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter a title' : null,
                    onSaved: (v) => _title = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: inputDeco("Condition"),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    borderRadius: BorderRadius.circular(16),
                    items: masterProvider.conditions
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _condition = v),
                    validator: (v) => v == null ? 'Select condition' : null,
                    onSaved: (v) => _condition = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: inputDeco(
                      "Description",
                      hint: "Describe the item's condition, features, etc.",
                    ).copyWith(alignLabelWithHint: true),
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textDark),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter description' : null,
                    onSaved: (v) => _description = v,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- PRICING ---
            _buildSectionHeader("Pricing"),
            _buildCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPoints = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isPoints
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isPoints
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    color: _isPoints
                                        ? Colors.amber
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Points",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isPoints
                                          ? AppColors.textDark
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (canSellCash) {
                                setState(() => _isPoints = false);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.orange.shade800,
                                    content: Text(
                                      eligibilityMessage ??
                                          "Cash selling is currently locked.",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isPoints
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: !_isPoints
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.currency_rupee_rounded,
                                    color: !_isPoints
                                        ? Colors.green
                                        : (canSellCash
                                              ? Colors.grey
                                              : Colors.grey.shade300),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Cash",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: !_isPoints
                                          ? AppColors.textDark
                                          : (canSellCash
                                                ? Colors.grey
                                                : Colors.grey.shade300),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: inputDeco(
                      _isPoints ? "Points Value" : "Price (INR)",
                      icon: _isPoints
                          ? Icons.stars_rounded
                          : Icons.currency_rupee_rounded,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter amount' : null,
                    onSaved: (v) => _price = double.tryParse(v ?? '0'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- CLASSIFICATION ---
            _buildSectionHeader("Classification"),
            _buildCard(
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: inputDeco(
                      "Category",
                      icon: Icons.category_rounded,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: catProvider.categories.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: _onCategoryChanged,
                    validator: (v) => v == null ? 'Select Category' : null,
                  ),
                  const SizedBox(height: 16),

                  // Animated Subcategory Section
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        if (_categoryId != null &&
                            catProvider.subCategories.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<int>(
                              key: ValueKey(_categoryId),
                              value: _subCategoryId,
                              decoration: inputDeco(
                                "Sub Category",
                                icon: Icons.subdirectory_arrow_right_rounded,
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              isExpanded: true,
                              items: catProvider.subCategories.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) =>
                                  setState(() => _subCategoryId = v),
                              onSaved: (v) => _subCategoryId = v,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: inputDeco("Gender"),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: masterProvider.genders
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _genderId = v),
                          validator: (v) => v == null ? 'Required' : null,
                          onSaved: (v) => _genderId = v,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: inputDeco("Age Group"),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          isExpanded: true,
                          items: masterProvider.ageGroups
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _ageGroupId = v),
                          validator: (v) => v == null ? 'Required' : null,
                          onSaved: (v) => _ageGroupId = v,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SPECIFICS ---
            _buildSectionHeader("Specifics"),
            _buildCard(
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: inputDeco(
                      "Material",
                      icon: Icons.layers_rounded,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: masterProvider.materials
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _materialId = v),
                    onSaved: (v) => _materialId = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: inputDeco("Color", icon: Icons.palette_rounded),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: masterProvider.colors.map((c) {
                      Widget colorPreview = const SizedBox();
                      if (c.hexCode != null) {
                        if (c.hexCode!.startsWith('#')) {
                          colorPreview = Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(c.hexCode!.replaceAll('#', '0xFF')),
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          );
                        } else if (c.hexCode!.contains('gradient')) {
                          colorPreview = Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          );
                        }
                      }
                      return DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            colorPreview,
                            const SizedBox(width: 12),
                            Text(c.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _colorId = v),
                    validator: (v) => v == null ? 'Select Color' : null,
                    onSaved: (v) => _colorId = v,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- SUBMIT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: prodProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: prodProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 22),
                          SizedBox(width: 12),
                          Text(
                            "List Item For Sale",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.withOpacity(0.9),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }
}
