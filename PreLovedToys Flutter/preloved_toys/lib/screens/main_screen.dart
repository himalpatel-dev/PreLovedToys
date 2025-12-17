import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:preloved_toys/providers/cart_provider.dart';
import 'package:preloved_toys/screens/cart_screen.dart';
import 'package:preloved_toys/screens/category_selection_screen.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'sell_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  bool _isBottomNavVisible = true;
  int? _initialCategoryId; // Store the selected category for the category tab

  void _toggleBottomNav(bool isVisible) {
    if (_isBottomNavVisible != isVisible) {
      setState(() {
        _isBottomNavVisible = isVisible;
      });
    }
  }

  void _navigateToCategory(int categoryId) {
    setState(() {
      _initialCategoryId = categoryId;
      _page = 1; // Switch to Category Tab
      _isBottomNavVisible = true;
    });
    // Also update the bottom nav bar visually if needed
    final navState = _bottomNavigationKey.currentState;
    navState?.setPage(1);
  }

  void _handleLogout(BuildContext context) async {
    //add confirm box that are you sure want to logout
    final shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (shouldLogout && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      // Check mounted again after the async logout operation
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _handleBackNavigation(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }

    if (_page != 0) {
      setState(() {
        _page = 0;
        _isBottomNavVisible = true;
        _initialCategoryId =
            null; // Reset category selection when going back to home
      });
      final navState = _bottomNavigationKey.currentState;
      navState?.setPage(0);
    } else {
      final shouldExit =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      // Use State's mounted property and context instead of callback parameter
      if (shouldExit && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- HEIGHT LOGIC ---
    // Only Home (0) gets the tall header (120). All others get standard (140).
    final double headerHeight = _page == 0 || _page == 1 || _page == 4
        ? 150.0
        : 120.0;

    // This must match the value used in your HeaderClipper (size.height - 50)
    const double curveDepth = 50.0;

    final List<Widget> screens = [
      HomeScreen(
        onScrollCallback: _toggleBottomNav,
        onCategorySelected: _navigateToCategory,
      ),
      CategorySelectionScreen(initialCategoryId: _initialCategoryId),
      const SellScreen(),
      const Center(child: Text("Message Content Here")),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBackNavigation,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.grey[50], // Consistent background
        body: Stack(
          children: [
            // --- 1. SCREEN CONTENT ---
            // The screens now slide up behind the curved edges
            Positioned.fill(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(top: headerHeight - curveDepth),
                child: screens[_page],
              ),
            ),

            // --- 2. CUSTOM CURVED HEADER ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: _buildCustomHeader(headerHeight),
            ),

            // --- 3. BOTTOM NAVIGATION ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _isBottomNavVisible ? 0 : -100,
              child: SafeArea(
                top: false,
                maintainBottomViewPadding: true,
                child: CurvedNavigationBar(
                  key: _bottomNavigationKey,
                  index: _page, // Ensure the index matches the page
                  height: 60.0,
                  color: AppColors.primary,
                  buttonBackgroundColor: AppColors.primary,
                  backgroundColor: Colors.transparent,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 400),
                  items: const <Widget>[
                    Icon(Icons.home_outlined, size: 30, color: Colors.white),
                    Icon(Icons.category_rounded, size: 30, color: Colors.white),
                    Icon(Icons.add_sharp, size: 30, color: Colors.white),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 30,
                      color: Colors.white,
                    ),
                    Icon(Icons.person_outline, size: 30, color: Colors.white),
                  ],
                  onTap: (index) {
                    setState(() {
                      _page = index;
                      _isBottomNavVisible = true;
                      // Optional: Reset initialCategoryId if manually navigating to categories?
                      // keeping it might be fine, or clearer to reset if they tap the tab manually.
                      // For now, let's leave it.
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER BUILDER ---
  Widget _buildCustomHeader(double currentHeight) {
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        color: AppColors.primary,
        // Adjust padding to center content vertically
        padding: _page == 0 || _page == 1 || _page == 4
            ? const EdgeInsets.fromLTRB(20, 25, 20, 20)
            : const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- HEADER CONTENT SWITCHER ---
            if (_page == 0 || _page == 1)
              _buildSearchCategoryHeaderContent() // Home & Category
            else if (_page == 2)
              _buildSimpleTitleContent("List your toy") // Sell Page
            else if (_page == 3)
              _buildSimpleTitleContent("Message") // Message Page
            else if (_page == 4)
              _buildProfileHeaderContent(), // Profile Page
          ],
        ),
      ),
    );
  }

  // --- 1. SEARCH & CATEGORY HEADER (Home, Category) ---
  Widget _buildSearchCategoryHeaderContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search for "Toys"',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textDark,
                  size: 24,
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return cart.items.isEmpty
                        ? const SizedBox()
                        : Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. SIMPLE TITLE HEADER (Sell, Message) ---
  Widget _buildSimpleTitleContent(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // --- 3. PROFILE HEADER (Profile) ---
  Widget _buildProfileHeaderContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.name ?? "Guest User",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.mobile ?? "No Mobile Number",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleLogout(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 25),
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var controlPoint = Offset(size.width / 2, size.height + 30);
    var endPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
