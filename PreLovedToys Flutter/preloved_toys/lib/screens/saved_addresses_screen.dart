import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/add_address_screen.dart';
import 'package:preloved_toys/widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../utils/app_colors.dart';
import '../models/address_model.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _hintController;
  late Animation<Offset> _hintAnimation;

  final Color _headerColor = AppColors.primary;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animation: Slide LEFT (-0.2) to simulate Right-to-Left swipe
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _hintAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.2, 0.0), // Negative X moves card to the LEFT
        ).animate(
          CurvedAnimation(
            parent: _hintController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

    // 2. Fetch & Trigger Hint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(
        context,
        listen: false,
      ).fetchAddresses().then((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _hintController.forward().then((_) {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) _hintController.reverse();
              });
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressData = Provider.of<AddressProvider>(context);
    final addresses = addressData.addresses;

    return Scaffold(
      backgroundColor: _headerColor,
      body: Column(
        children: [
          // --- Custom Header ---
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
                        "Shipping Address",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // RIGHT: Add Button (visible)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditAddressScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Curved sheet with content ---
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
                      child: addressData.isLoading
                          ? const Center(
                              child: BouncingDiceLoader(
                                color: AppColors.primary,
                              ),
                            )
                          : Column(
                              children: [
                                // Top row inside sheet: Add button aligned right (kept for convenience)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    18,
                                    16,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(child: SizedBox()),

                                      // Add button (secondary)
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddEditAddressScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // The list / empty state
                                Expanded(
                                  child: addresses.isEmpty
                                      ? const Center(
                                          child: Text("No addresses saved."),
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.all(20),
                                          itemCount: addresses.length,
                                          separatorBuilder: (ctx, i) =>
                                              const SizedBox(height: 20),
                                          itemBuilder: (ctx, index) {
                                            final address = addresses[index];

                                            // Only animate the FIRST item for the hint
                                            if (index == 0) {
                                              return _buildAnimatedDismissibleItem(
                                                address,
                                              );
                                            }

                                            return _buildDismissibleItem(
                                              address,
                                            );
                                          },
                                        ),
                                ),
                              ],
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

  // --- ANIMATED WRAPPER (For the Hint) ---
  Widget _buildAnimatedDismissibleItem(Address address) {
    return Stack(
      children: [
        // A. FAKE BACKGROUND (Behind the card)
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.only(right: 20), // Padding on RIGHT
            alignment: Alignment.centerRight, // Icon on RIGHT
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
        ),

        // B. THE SLIDING CARD
        SlideTransition(
          position: _hintAnimation,
          child: _buildDismissibleItem(address),
        ),
      ],
    );
  }

  // --- ACTUAL DISMISSIBLE ITEM ---
  Widget _buildDismissibleItem(Address address) {
    return Dismissible(
      key: ValueKey(address.id),
      direction: DismissDirection.endToStart, // Swipe Right -> Left
      background: Container(
        padding: const EdgeInsets.only(right: 20), // Padding on RIGHT
        alignment: Alignment.centerRight, // Icon on RIGHT
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Address?"),
            content: const Text(
              "Are you sure you want to remove this address?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<AddressProvider>(
          context,
          listen: false,
        ).deleteAddress(address.id);
      },
      child: _buildAddressCard(address),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: _buildAddressTypeIcon(address.addressType),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.receiverName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            address.addressType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.phoneNumber,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditAddressScreen(address: address),
                    ),
                  );
                },
                child: Icon(
                  Icons.edit_outlined,
                  size: 22,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 55),
            child: Text(
              address.fullAddress,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 15),
          if (address.isDefault)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      "Default Address",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: TextButton(
                onPressed: () {
                  Provider.of<AddressProvider>(
                    context,
                    listen: false,
                  ).setDefaultAddress(address.id);
                },
                child: const Text(
                  "Set as Default",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // add icon to replace that location icon based on address type
  Widget _buildAddressTypeIcon(String type) {
    switch (type) {
      case "Home":
        return const Icon(Icons.home, color: AppColors.primary);
      case "Work":
        return const Icon(Icons.work, color: AppColors.primary);
      case "Other":
        return const Icon(Icons.location_on, color: AppColors.primary);
      default:
        return const Icon(Icons.location_on, color: AppColors.primary);
    }
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
