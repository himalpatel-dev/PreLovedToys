import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/address_provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../models/address_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _pincodeController;
  // Removed _stateController (now using _selectedState)
  late TextEditingController _cityController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController
  _countryController; // Kept for logic, hidden from UI

  String _selectedType = "Home";
  bool _isDefault = false;
  String? _selectedState; // For Dropdown

  // List of Indian States & UTs
  final List<String> _indianStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli",
    "Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
  ];

  @override
  void initState() {
    super.initState();
    final addr = widget.address;

    // 1. GET USER DATA FOR AUTO-FILL
    // We listen: false because we just need data once, not updates
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    // 2. INITIALIZE CONTROLLERS
    // If Editing: Use address data
    // If Adding: Use User data (Auto-fill)
    _nameController = TextEditingController(
      text: addr?.receiverName ?? user?.name ?? '',
    );
    _phoneController = TextEditingController(
      text: addr?.phoneNumber ?? user?.mobile ?? '',
    );

    _pincodeController = TextEditingController(text: addr?.pincode ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _address1Controller = TextEditingController(text: addr?.addressLine1 ?? '');
    _address2Controller = TextEditingController(text: addr?.addressLine2 ?? '');
    _countryController = TextEditingController(
      text: addr?.country ?? 'India',
    ); // Default to India

    if (addr != null) {
      _selectedType = addr.addressType;
      _isDefault = addr.isDefault;
      // Ensure the saved state exists in our list, otherwise add it or handle error
      if (_indianStates.contains(addr.state)) {
        _selectedState = addr.state;
      } else if (addr.state.isNotEmpty) {
        _selectedState =
            null; // Or add addr.state to list if you want to support custom
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    if (widget.address == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Provider.of<AddressProvider>(
                  context,
                  listen: false,
                ).deleteAddress(widget.address!.id);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final formData = {
      "receiver_name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "pincode": _pincodeController.text.trim(),
      "address_line1": _address1Controller.text.trim(),
      "address_line2": _address2Controller.text.trim(),
      "city": _cityController.text.trim(),
      "state": _selectedState, // Use dropdown value
      "country": _countryController.text.trim(), // Hidden but sent
      "address_type": _selectedType,
      "is_default": _isDefault,
    };

    final provider = Provider.of<AddressProvider>(context, listen: false);

    try {
      if (widget.address == null) {
        await provider.addAddress(formData);
      } else {
        await provider.updateAddress(widget.address!.id, formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null ? "Address Added!" : "Address Updated!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AddressProvider>(context).isLoading;
    final isEditing = widget.address != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Address" : "Add New Address",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: ["Home", "Work", "Other"].map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      checkmarkColor: Colors.white,
                      selectedColor: AppColors.primary,
                      backgroundColor: const Color(0xFFF5F6F9),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = type);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              const Text(
                "Contact Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Pre-filled with User Name
              _buildTextField(
                "Receiver Name*",
                _nameController,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 15),
              // Pre-filled with User Mobile
              _buildTextField(
                "Phone Number*",
                _phoneController,
                keyboardType: TextInputType.phone,
                validator: _phoneValidator,
              ),

              const SizedBox(height: 25),

              const Text(
                "Address Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "House No., Building Name*",
                _address1Controller,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                "Road Name, Area, Colony (Optional)",
                _address2Controller,
              ),
              const SizedBox(height: 15),

              _buildTextField(
                "Pincode*",
                _pincodeController,
                keyboardType: TextInputType.number,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align top incase of errors
                children: [
                  Expanded(
                    child: _buildTextField(
                      "City*",
                      _cityController,
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 15),

                  // --- STATE DROPDOWN ---
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedState,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "State*",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
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
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                      ),
                      menuMaxHeight: 300, // Limit dropdown height
                      items: _indianStates.map((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(
                            state,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedState = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Make this my default address",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: _isDefault,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _isDefault = val),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? "Update Address" : "Save Address",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F6F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Required";
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Required";
    if (value.length < 10) return "Invalid Phone Number";
    return null;
  }
}
