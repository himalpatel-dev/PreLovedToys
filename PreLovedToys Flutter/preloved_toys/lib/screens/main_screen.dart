import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  bool _isBottomNavVisible = true;

  void _toggleBottomNav(bool isVisible) {
    if (_isBottomNavVisible != isVisible) {
      setState(() {
        _isBottomNavVisible = isVisible;
      });
    }
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_page != 0) {
      setState(() {
        _page = 0;
        _isBottomNavVisible = true;
      });
      final navState = _bottomNavigationKey.currentState;
      navState?.setPage(0);
      return false;
    } else {
      return await showDialog(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- HEIGHT LOGIC ---
    // Only Home (0) gets the tall header (120). All others get standard (140).
    final double headerHeight = _page == 0 ? 130.0 : 150.0;

    // This must match the value used in your HeaderClipper (size.height - 50)
    const double curveDepth = 50.0;

    final List<Widget> screens = [
      Padding(
        // SUBTRACT the curve depth so content starts at the "shoulders" of the header
        padding: EdgeInsets.only(top: headerHeight - curveDepth),
        child: HomeScreen(onScrollCallback: _toggleBottomNav),
      ),
      Padding(
        padding: EdgeInsets.only(top: headerHeight - curveDepth),
        child: const CartScreen(),
      ),
      Padding(
        padding: EdgeInsets.only(top: headerHeight - curveDepth),
        child: const Center(child: Text("Sell Content Here")),
      ),
      Padding(
        padding: EdgeInsets.only(top: headerHeight - curveDepth),
        child: const Center(child: Text("Message Content Here")),
      ),
      Padding(
        padding: EdgeInsets.only(top: headerHeight - curveDepth),
        child: const ProfileScreen(),
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            // --- 1. SCREEN CONTENT ---
            // The screens now slide up behind the curved edges
            Positioned.fill(child: screens[_page]),

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
                  index: 0,
                  height: 60.0,
                  color: AppColors.primary,
                  buttonBackgroundColor: AppColors.primary,
                  backgroundColor: Colors.transparent,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 400),
                  items: const <Widget>[
                    Icon(Icons.home_outlined, size: 30, color: Colors.white),
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      size: 30,
                      color: Colors.white,
                    ),
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
      clipper: _page == 0 ? null : HeaderClipper(),
      child: Container(
        color: AppColors.primary,
        // Adjust padding to center content vertically
        padding: EdgeInsets.fromLTRB(20, 10, 20, _page == 0 ? 0 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- HEADER CONTENT SWITCHER ---
            if (_page == 0 || _page == 1)
              _buildSearchCartHeaderContent() // Home & Cart
            else if (_page == 2)
              _buildSimpleTitleContent("Sell") // Sell Page
            else if (_page == 3)
              _buildSimpleTitleContent("Message") // Message Page
            else if (_page == 4)
              _buildProfileHeaderContent(), // Profile Page
          ],
        ),
      ),
    );
  }

  // --- 1. SEARCH & CART HEADER (Home, Cart) ---
  Widget _buildSearchCartHeaderContent() {
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
            setState(() {
              _page = 1;
              _isBottomNavVisible = true;
            });
            _bottomNavigationKey.currentState?.setPage(1);
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
          fontSize: 28,
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
