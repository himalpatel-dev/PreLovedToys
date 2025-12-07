import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

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
  final _occupationController = TextEditingController();
  final _collegeController = TextEditingController();
  final _purposeController = TextEditingController();
  final _aboutController = TextEditingController();
  final _interestsController = TextEditingController();

  String? _selectedGender;

  // Points Config (Matches your Backend)
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

  // Track initial empty state to know if points are available
  Map<String, bool> _wasEmptyInitially = {};

  @override
  void initState() {
    super.initState();
    // Load existing data
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _occupationController.text = user.occupation ?? '';
      _collegeController.text = user.collegeOrUniversity ?? '';
      _purposeController.text = user.purpose ?? '';
      _aboutController.text = user.aboutMe ?? '';

      // Handle Interest Array or String
      if (user.interestedIn != null) {
        _interestsController.text = user.interestedIn!.join(', ');
      }

      _selectedGender = user.gender;

      // Determine which fields were empty initially (Eligible for points)
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

  bool _isEmpty(String? val) {
    return val == null || val.trim().isEmpty;
  }

  // Calculate points user WILL earn if they save now
  int _calculatePotentialPoints() {
    int total = 0;
    if (_wasEmptyInitially['name']! && _nameController.text.isNotEmpty)
      total += 20;
    if (_wasEmptyInitially['email']! && _emailController.text.isNotEmpty)
      total += 30;
    if (_wasEmptyInitially['occupation']! &&
        _occupationController.text.isNotEmpty)
      total += 20;
    if (_wasEmptyInitially['collegeOrUniversity']! &&
        _collegeController.text.isNotEmpty)
      total += 20;
    if (_wasEmptyInitially['purpose']! && _purposeController.text.isNotEmpty)
      total += 30;
    if (_wasEmptyInitially['aboutMe']! && _aboutController.text.isNotEmpty)
      total += 30;
    if (_wasEmptyInitially['interestedIn']! &&
        _interestsController.text.isNotEmpty)
      total += 30;
    if (_wasEmptyInitially['gender']! && _selectedGender != null) total += 20;
    return total;
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> updates = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'occupation': _occupationController.text.trim(),
      'collegeOrUniversity': _collegeController.text.trim(),
      'purpose': _purposeController.text.trim(),
      'aboutMe': _aboutController.text.trim(),
      'gender': _selectedGender,
      // Convert comma separated string back to array for backend
      'interestedIn': _interestsController.text
          .split(',')
          .map((e) => e.trim())
          .toList(),
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
        Navigator.pop(context); // Go back
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
      // Bottom Bar showing potential points
      bottomNavigationBar: potentialPoints > 0
          ? Container(
              color: const Color(0xFFE8F5E9), // Light Green
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    "Complete changes to earn $potentialPoints Points!",
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
          onChanged: () {
            setState(() {}); // Refresh UI to update point calculation
          },
          child: Column(
            children: [
              _buildTextField("Full Name", _nameController, 'name'),
              const SizedBox(height: 15),
              _buildTextField(
                "Email Address",
                _emailController,
                'email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Gender Dropdown
              _buildLabelWithPoints("Gender", 'gender'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    hint: const Text("Select Gender"),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),
              _buildTextField(
                "Occupation",
                _occupationController,
                'occupation',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "College / University",
                _collegeController,
                'collegeOrUniversity',
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Purpose on Platform",
                _purposeController,
                'purpose',
                hint: "Buying, Selling, Browsing...",
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Interests",
                _interestsController,
                'interestedIn',
                hint: "Lego, Cars, Dolls (comma separated)",
              ),
              const SizedBox(height: 15),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String fieldKey, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF5F6F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelWithPoints(String label, String fieldKey) {
    // Only show points badge if the field was EMPTY initially
    final bool showPoints = _wasEmptyInitially[fieldKey] ?? false;
    final int points = _pointsMap[fieldKey] ?? 0;

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        if (showPoints) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Light Green
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
