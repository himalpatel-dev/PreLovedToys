import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/add_address_screen.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
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

    final Color headerColor = AppColors.primary;

    return Scaffold(
      backgroundColor: headerColor,
      body: Column(
        children: [
          // --- Custom Header (safe area) ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Back Button
                  _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),

                  // CENTER: Title
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Address",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // RIGHT: Invisible button to balance the row
                  _buildCircleButton(
                    icon: Icons.add,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditAddressScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // --- THE CURVED WHITE SHEET ---
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
                        color: Colors
                            .transparent, // This element seems unused or is meant as a small drag indicator
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Content Area - CONDITIONAL LOGIC HERE
                    addressProvider.isLoading
                        ? Expanded(
                            // Expanded ensures the loader takes up the remaining space
                            child: Center(
                              child: BouncingDiceLoader(
                                // Your custom loader
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- HEADER TEXT ---
                                  const Text(
                                    "Choose your location",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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

                                  // --- ADDRESS LIST ---
                                  if (addresses.isEmpty)
                                    const Center(
                                      child: Text("No addresses found."),
                                    )
                                  else
                                    ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: addresses.length,
                                      separatorBuilder: (ctx, i) =>
                                          const SizedBox(height: 15),
                                      itemBuilder: (ctx, index) {
                                        return _buildAddressCard(
                                          addresses[index],
                                        );
                                      },
                                    ),

                                  // keep some bottom spacing so confirm button isn't too close
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),

                    // --- BOTTOM CONFIRM BUTTON (outside the conditional area) ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          // ... button logic remains the same
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
                            backgroundColor: AppColors.primary,
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
                  ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 5,
                  ),
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
