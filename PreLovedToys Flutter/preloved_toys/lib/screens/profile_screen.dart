import 'package:flutter/material.dart';
import 'package:preloved_toys/screens/my_favorites_screen.dart';
import 'package:preloved_toys/screens/my_listings_screen.dart';
import 'package:preloved_toys/screens/privacy_policy_screen.dart';
import 'package:preloved_toys/screens/saved_addresses_screen.dart';
import 'package:preloved_toys/screens/terms_and_conditions_screen.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../widgets/custom_loader.dart';
import 'my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh stats silently in background when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for global changes
    final authProvider = Provider.of<AuthProvider>(context);
    final stats = authProvider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      // STEP 1: Use a Column instead of SingleChildScrollView
      body: Column(
        children: [
          // --- FIXED HEADER SECTION (Non-scrollable) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              0,
            ), // Maintain side padding
            child: Column(
              children: [
                const SizedBox(height: 50), // Keep your top spacing
                // --- 2. STATS CARD (Always Visible) ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(stats['orders']!, "Total Orders"),
                      _buildVerticalLine(),
                      _buildStatItem(stats['sells']!, "Total Sell"),
                      _buildVerticalLine(),
                      _buildStatItem(
                        stats['points']!,
                        "My Points",
                        isPoints: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- SCROLLABLE CONTENT SECTION (Fills remaining space) ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ), // Maintain side padding
              child: Column(
                children: [
                  const SizedBox(height: 20), // Spacing between Stats and Menu
                  // --- 3. MAIN MENU CARD ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          Icons.person,
                          "Personal Details",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            if (context.mounted) {
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).fetchUserStats();
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.shopping_bag,
                          "My Order",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.favorite,
                          "My Favourites",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyFavoritesScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.inventory_2,
                          "My Listings",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyListingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.local_shipping,
                          "Shipping Address",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SavedAddressesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 4. FOOTER MENU ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          Icons.settings,
                          "Support Center",
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.description_outlined,
                          "Terms & Conditions",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsAndConditionsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          Icons.privacy_tip_outlined,
                          "Privacy Policy",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isPoints = false}) {
    // Small check: If value is '-' (still fetching), show mini-horse or just wait
    Widget content;
    if (value == '-') {
      content = const SizedBox(
        height: 30,
        width: 30,
        child: BouncingDiceLoader(color: AppColors.primary, size: 30),
      );
    } else {
      content = Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isPoints)
              const Padding(
                padding: EdgeInsets.only(bottom: 4, right: 2),
                child: Icon(Icons.stars, color: Colors.amber, size: 18),
              ),
            content,
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 70,
    );
  }
}
