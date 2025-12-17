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

  final List<String> _imageUrls = []; // Store image URLs (Mocking for now)

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<MasterDataProvider>(context, listen: false).fetchMasterData();
    });
  }

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

    // Common Dropdown Decoration
    InputDecoration dropDeco(String label, {IconData? icon}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 40),

            // --- PHOTOS SECTION ---
            _buildSectionCard(
              title: "Product Photos",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add at least 1 photo. First photo is your cover.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageUrls.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.5),
                                  style: BorderStyle.solid,
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: AppColors.primary,
                                    size: 30,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Add Photo",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
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
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(url),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index - 1),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- BASIC INFO ---
            _buildSectionCard(
              title: "Item Details",
              child: Column(
                children: [
                  TextFormField(
                    decoration: dropDeco("Product Title", icon: Icons.title),
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter a title' : null,
                    onSaved: (v) => _title = v,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: dropDeco("Condition", icon: Icons.star_outline),
                    dropdownColor: Colors.white,
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
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: dropDeco(
                      "Item Description",
                      icon: Icons.description_outlined,
                    ).copyWith(alignLabelWithHint: false),
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter description' : null,
                    onSaved: (v) => _description = v,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- PRICING ---
            _buildSectionCard(
              title: "Pricing Details",
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: dropDeco(
                            "Amount",
                            icon: _isPoints
                                ? Icons.stars
                                : Icons.currency_rupee,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Enter value' : null,
                          onSaved: (v) => _price = double.tryParse(v ?? '0'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Styled Currency Toggle
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          height: 56, // Match standard input height roughly
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isPoints = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isPoints
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: _isPoints
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Points",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isPoints
                                            ? AppColors.primary
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _isPoints = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: !_isPoints
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: !_isPoints
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Cash",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !_isPoints
                                            ? AppColors.primary
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- ATTRIBUTES ---
            _buildSectionCard(
              title: "Classification",
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    dropdownColor: Colors.white,
                    decoration: dropDeco(
                      "Category",
                      icon: Icons.category_sharp,
                    ),
                    items: catProvider.categories.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: _onCategoryChanged,
                    validator: (v) => v == null ? 'Select Category' : null,
                  ),
                  const SizedBox(height: 15),
                  if (catProvider.isSubLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_categoryId != null &&
                      catProvider.subCategories.isNotEmpty) ...[
                    DropdownButtonFormField<int>(
                      key: ValueKey(_categoryId),
                      value: _subCategoryId,
                      dropdownColor: Colors.white,
                      isExpanded: true, // Fixes overflow by constraining width
                      decoration: dropDeco(
                        "Sub Category",
                        icon: Icons.category_outlined,
                      ),
                      items: catProvider.subCategories.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(
                            c.name,
                            overflow:
                                TextOverflow.ellipsis, // Truncate long text
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _subCategoryId = v),
                      onSaved: (v) => _subCategoryId = v,
                    ),
                    const SizedBox(height: 15),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: dropDeco(
                            "Gender",
                            icon: Icons.people_outline,
                          ),
                          dropdownColor: Colors.white,
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: dropDeco("Age", icon: Icons.child_care),
                          dropdownColor: Colors.white,
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

            const SizedBox(height: 20),

            // --- SPECIFICS ---
            _buildSectionCard(
              title: "Specifics",
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: dropDeco(
                      "Material",
                      icon: Icons.layers_outlined,
                    ),
                    dropdownColor: Colors.white,
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
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    decoration: dropDeco(
                      "Color",
                      icon: Icons.color_lens_outlined,
                    ),
                    dropdownColor: Colors.white,
                    items: masterProvider.colors.map((c) {
                      Widget colorPreview = const SizedBox();
                      if (c.hexCode != null) {
                        if (c.hexCode!.startsWith('#')) {
                          colorPreview = Container(
                            width: 18,
                            height: 18,
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
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.orange,
                                  Colors.yellow,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.purple,
                                ],
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
                            const SizedBox(width: 10),
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
              height: 55,
              child: ElevatedButton(
                onPressed: prodProvider.isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 5,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                          Icon(Icons.check_circle_outline, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "List Item For Sale",
                            style: TextStyle(
                              fontSize: 18,
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          Divider(color: Colors.grey.withOpacity(0.2), height: 20),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
