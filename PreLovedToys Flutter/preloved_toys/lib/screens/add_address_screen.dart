import 'package:flutter/material.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
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
  late TextEditingController _cityController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _countryController;

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

  final Color _headerColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;

    // 1. GET USER DATA FOR AUTO-FILL
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    // 2. INITIALIZE CONTROLLERS
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
      // Ensure the saved state exists in our list, otherwise ignore
      if (_indianStates.contains(addr.state)) {
        _selectedState = addr.state;
      } else if (addr.state.isNotEmpty) {
        _selectedState = null; // Or add addr.state to list if you want custom
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
                // The provider will automatically update its isLoading state
                await Provider.of<AddressProvider>(
                  context,
                  listen: false,
                ).deleteAddress(widget.address!.id);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
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

    // The logic to handle loading screen is implicitly managed by AddressProvider's isLoading state
    // since this function calls provider methods which should set that state to true/false.

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
    // No finally block needed here, as AddressProvider should manage
    // setting `isLoading` back to false within its methods.
  }

  @override
  Widget build(BuildContext context) {
    // Get the loading state from the provider
    final isLoading = Provider.of<AddressProvider>(context).isLoading;
    final isEditing = widget.address != null;

    return Scaffold(
      backgroundColor: _headerColor,
      // --- WRAP BODY IN STACK FOR LOADER OVERLAY ---
      body: Stack(
        children: [
          // --- Main Content ---
          Column(
            children: [
              // --- Custom Header (now shows delete when editing) ---
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT: Back Button
                      _buildCircleButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),

                      // CENTER: Title
                      Expanded(
                        child: Center(
                          child: Text(
                            isEditing ? "Edit Address" : "Add New Address",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // RIGHT: Delete button (visible only when editing)
                      isEditing
                          ? GestureDetector(
                              onTap: _handleDelete,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            )
                          : Opacity(
                              opacity: 0,
                              child: _buildCircleButton(
                                icon: Icons.more_horiz,
                                onTap: () {},
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              // --- Curved sheet ---
              Expanded(
                child: ClipPath(
                  clipper: TopConvexClipper(),
                  child: Container(
                    color: const Color(0xFFF9F9F9),
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Content area
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Type chips
                                Wrap(
                                  spacing: 10,
                                  children: ["Home", "Work", "Other"].map((
                                    type,
                                  ) {
                                    final isSelected = _selectedType == type;
                                    return ChoiceChip(
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                      ),
                                      label: Text(type),
                                      selected: isSelected,
                                      checkmarkColor: Colors.white,
                                      selectedColor: AppColors.primary,
                                      backgroundColor: const Color(0xFFF5F6F9),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide.none,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedType = type);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 15),
                                const Text(
                                  "Contact Details",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Pre-filled with User Name
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                            CrossAxisAlignment.start,
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
                                              initialValue: _selectedState,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                              ),
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                labelText: "State*",
                                                labelStyle: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                                filled: true,
                                                fillColor: const Color(
                                                  0xFFF5F6F9,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: AppColors
                                                                .primary,
                                                            width: 1.5,
                                                          ),
                                                    ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              menuMaxHeight: 300,
                                              items: _indianStates.map((
                                                String state,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  value: state,
                                                  child: Text(
                                                    state,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) => setState(
                                                () => _selectedState = val,
                                              ),
                                              validator: (val) => val == null
                                                  ? 'Required'
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                          "Make this my default address",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        value: _isDefault,
                                        activeThumbColor: AppColors.primary,
                                        onChanged: (val) =>
                                            setState(() => _isDefault = val),
                                      ),

                                      const SizedBox(height: 10),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton(
                                          // Disable button if loading
                                          onPressed: isLoading
                                              ? null
                                              : _handleSave,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: Text(
                                            isEditing
                                                ? "Update Address"
                                                : "Save Address",
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- FULL-SCREEN LOADER OVERLAY ---
          if (isLoading) _buildLoadingOverlay(context),
        ],
      ),
    );
  }

  // --- NEW HELPER WIDGET FOR LOADING OVERLAY ---
  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(120), // Semi-transparent black background
      child: const Center(child: BouncingDiceLoader(color: AppColors.primary)),
    );
  }

  // --- Existing Helper Widgets ---

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

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

/// Custom clipper that creates a centered upward arch (convex/hill)
class TopConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // The vertical height of the curve (how much it arches)
    double curveHeight = 40.0;

    path.moveTo(0, curveHeight);
    path.quadraticBezierTo(size.width / 2, 0, size.width, curveHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
