import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

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

  // --- NEW: Handle Back Button Logic ---
  Future<bool> _onWillPop() async {
    // 1. If currently NOT on Home Tab (Index 0), go back to Home
    if (_page != 0) {
      setState(() {
        _page = 0;
        _isBottomNavVisible = true; // Ensure nav bar is visible
      });
      // Update the visual tab bar to select Home
      final navState = _bottomNavigationKey.currentState;
      navState?.setPage(0);

      return false; // Do NOT exit app
    }
    // 2. If already on Home Tab, show Exit Dialog
    else {
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
                  onPressed: () => Navigator.of(context).pop(false), // Stay
                  child: const Text('No', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Exit
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
          false; // Default to false (stay) if dialog is dismissed
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onScrollCallback: _toggleBottomNav),
      const CartScreen(),
      const Center(child: Text("Sell Screen", style: TextStyle(fontSize: 24))),
      const Center(
        child: Text("Message Screen", style: TextStyle(fontSize: 24)),
      ),
      const ProfileScreen(),
    ];

    // Wrap the Scaffold with WillPopScope to intercept the back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.grey[50],

        body: Stack(
          children: [
            Positioned.fill(child: screens[_page]),

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
                  items: <Widget>[
                    Icon(Icons.home_outlined, size: 30, color: Colors.white),
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                    Icon(Icons.explore_outlined, size: 30, color: Colors.white),
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
}
