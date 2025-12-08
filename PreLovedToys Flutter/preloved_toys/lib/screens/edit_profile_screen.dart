import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _collegeController = TextEditingController();
  final _aboutController = TextEditingController();

  // State for Selection Fields
  String? _selectedGender;
  String? _selectedOccupation;
  List<String> _selectedInterests = [];
  List<String> _selectedPurposes = [];

  // Options Lists
  final List<String> _purposeOptions = [
    'Make Extra Income',
    'Donate / Charity',
    'Swap / Trade',
    'Seasonal Sell',
    'Test New Toys',
    'Friendly Seller',
    'Open to Negotiation',
  ];

  final List<String> _occupationOptions = [
    'Student',
    'Parent',
    'Freelancer',
    'Self-Employed',
    'Shop Owner',
    'Business Owner',
    'Homemaker',
    'Play School Staff',
    'Other',
  ];

  final Map<String, int> _pointsMap = {
    'name': 20,
    'email': 30,
    'gender': 20,
    'occupation': 20,
    'collegeOrUniversity': 20,
    'purpose': 30,
    'aboutMe': 30,
    'interestedIn': 30,
  };

  Map<String, bool> _wasEmptyInitially = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _collegeController.text = user.collegeOrUniversity ?? '';
      _aboutController.text = user.aboutMe ?? '';

      if (user.gender != null) {
        String dbGender = user.gender!.trim();
        if (dbGender.isNotEmpty) {
          _selectedGender = dbGender[0].toUpperCase() + dbGender.substring(1);
        }
      }

      if (user.occupation != null && user.occupation!.isNotEmpty) {
        _selectedOccupation = user.occupation;
        if (!_occupationOptions.contains(_selectedOccupation)) {
          _occupationOptions.add(_selectedOccupation!);
        }
      }

      if (user.interestedIn != null) {
        _selectedInterests = List.from(user.interestedIn!);
      }

      if (user.purpose != null && user.purpose!.isNotEmpty) {
        _selectedPurposes = user.purpose!
            .split(',')
            .map((e) => e.trim())
            .toList();
      }

      _wasEmptyInitially = {
        'name': _isEmpty(user.name),
        'email': _isEmpty(user.email),
        'gender': _isEmpty(user.gender),
        'occupation': _isEmpty(user.occupation),
        'collegeOrUniversity': _isEmpty(user.collegeOrUniversity),
        'purpose': _isEmpty(user.purpose),
        'aboutMe': _isEmpty(user.aboutMe),
        'interestedIn':
            (user.interestedIn == null || user.interestedIn!.isEmpty),
      };
    }
  }

  bool _isEmpty(String? val) => val == null || val.trim().isEmpty;

  int _calculatePotentialPoints() {
    int total = 0;
    bool eligible(String key) => _wasEmptyInitially[key] ?? false;

    if (eligible('name') && _nameController.text.isNotEmpty) total += 20;
    if (eligible('email') && _emailController.text.isNotEmpty) total += 30;
    if (eligible('collegeOrUniversity') && _collegeController.text.isNotEmpty)
      total += 20;
    if (eligible('aboutMe') && _aboutController.text.isNotEmpty) total += 30;
    if (eligible('gender') && _selectedGender != null) total += 20;
    if (eligible('occupation') && _selectedOccupation != null) total += 20;
    if (eligible('purpose') && _selectedPurposes.isNotEmpty) total += 30;
    if (eligible('interestedIn') && _selectedInterests.isNotEmpty) total += 30;

    return total;
  }

  void _handleSave() async {
    // 1. THIS TRIGGERS THE VALIDATION (RED TEXT)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the required fields (Name & Email)'),
        ),
      );
      return;
    }

    final Map<String, dynamic> updates = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'collegeOrUniversity': _collegeController.text.trim(),
      'aboutMe': _aboutController.text.trim(),
      'gender': _selectedGender,
      'occupation': _selectedOccupation,
      'interestedIn': _selectedInterests,
      'purpose': _selectedPurposes.join(', '),
    };

    try {
      final response = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).updateProfile(updates);

      if (mounted) {
        final points = response['pointsCredited'] ?? 0;
        final message = points > 0
            ? 'Profile Updated! You earned $points points! 🎉'
            : 'Profile Updated Successfully';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: points > 0 ? Colors.green : AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final potentialPoints = _calculatePotentialPoints();
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    final categories = Provider.of<CategoryProvider>(context).categories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Personal Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      bottomNavigationBar: potentialPoints > 0
          ? Container(
              color: const Color(0xFFE8F5E9),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    "Complete to earn $potentialPoints Points!",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NAME (REQUIRED) ---
              _buildTextField(
                "Full Name *", // Added star to label
                _nameController,
                'name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- EMAIL (REQUIRED) ---
              _buildTextField(
                "Email Address *",
                _emailController,
                'email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  // Simple Email Regex check
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabelWithPoints("Gender", 'gender'),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female', 'Other'].map((gender) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: gender,
                        groupValue: _selectedGender,
                        activeColor: AppColors.primary,
                        onChanged: (val) =>
                            setState(() => _selectedGender = val),
                      ),
                      Text(gender, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _buildLabelWithPoints("Occupation", 'occupation'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _occupationOptions.map((occupation) {
                  final isSelected = _selectedOccupation == occupation;
                  return ChoiceChip(
                    label: Text(occupation),
                    selected: isSelected,
                    checkmarkColor: Colors.white,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF5F6F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedOccupation = selected ? occupation : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _buildTextField(
                "College / University",
                _collegeController,
                'collegeOrUniversity',
              ),

              const SizedBox(height: 20),

              _buildLabelWithPoints("Purpose on Platform", 'purpose'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _purposeOptions.map((purpose) {
                  final isSelected = _selectedPurposes.contains(purpose);
                  return FilterChip(
                    label: Text(purpose),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF5F6F9),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedPurposes.add(purpose);
                        } else {
                          _selectedPurposes.remove(purpose);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _buildLabelWithPoints("Interests", 'interestedIn'),
              const SizedBox(height: 10),
              if (categories.isEmpty)
                const Text(
                  "Loading interests...",
                  style: TextStyle(color: Colors.grey),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = _selectedInterests.contains(cat.name);
                  return FilterChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF5F6F9),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(cat.name);
                        } else {
                          _selectedInterests.remove(cat.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _buildTextField(
                "About Me",
                _aboutController,
                'aboutMe',
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED HELPER WIDGET (Now accepts validator)
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String fieldKey, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelWithPoints(label, fieldKey),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator, // <--- Passes the check function here
          autovalidateMode: AutovalidateMode
              .onUserInteraction, // Shows error as you type (optional)
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              // Red border on error
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelWithPoints(String label, String fieldKey) {
    final bool showPoints = _wasEmptyInitially[fieldKey] ?? false;
    final int points = _pointsMap[fieldKey] ?? 0;

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            fontSize: 15,
          ),
        ),
        if (showPoints) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle, size: 10, color: Colors.green),
                const SizedBox(width: 2),
                Text(
                  "$points pts",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
