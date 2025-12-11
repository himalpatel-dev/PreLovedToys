import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../models/address_model.dart';
import '../utils/app_colors.dart';

class AddressSelectionScreen extends StatefulWidget {
  final int? selectedId; // Pass the current ID to highlight it

  const AddressSelectionScreen({super.key, this.selectedId});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _selectedAddressId = widget.selectedId;
    // Fetch latest addresses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Address",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER TEXT ---
                  const Text(
                    "Choose your location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's find your unforgettable event. Choose a location below to get started.",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- SEARCH BAR (Visual Only) ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textDark,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "San Diego, CA", // Placeholder text
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(Icons.my_location, color: Colors.grey[400]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Select location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // --- ADDRESS LIST ---
                  if (addressProvider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (addresses.isEmpty)
                    const Center(child: Text("No addresses found."))
                  else
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                      itemBuilder: (ctx, index) {
                        return _buildAddressCard(addresses[index]);
                      },
                    ),
                ],
              ),
            ),
          ),

          // --- BOTTOM CONFIRM BUTTON ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Return the selected address object back to Checkout
                    if (_selectedAddressId != null) {
                      try {
                        final selectedAddr = addresses.firstWhere(
                          (a) => a.id == _selectedAddressId,
                        );
                        Navigator.pop(context, selectedAddr);
                      } catch (e) {
                        Navigator.pop(context);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary, // Using your purple color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    final isSelected = _selectedAddressId == address.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressId = address.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey[200]!, // Purple if selected
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Left Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.city, // Title (e.g., Los Angeles)
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${address.addressLine1}, ${address.state}", // Subtitle
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right Map Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.location_on,
                  color: isSelected ? AppColors.primary : Colors.pinkAccent,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
