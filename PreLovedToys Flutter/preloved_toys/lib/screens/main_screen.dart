import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // State to control visibility
  bool _isBottomNavVisible = true;

  // Toggle function passed to Home
  void _toggleBottomNav(bool isVisible) {
    if (_isBottomNavVisible != isVisible) {
      setState(() {
        _isBottomNavVisible = isVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screens list
    final List<Widget> screens = [
      HomeScreen(onScrollCallback: _toggleBottomNav),
      const Center(
        child: Text("Search Screen", style: TextStyle(fontSize: 24)),
      ),
      const Center(child: Text("Sell Screen", style: TextStyle(fontSize: 24))),
      const Center(
        child: Text("Message Screen", style: TextStyle(fontSize: 24)),
      ),
      const ProfileScreen(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: true, // Content goes behind the bar
        backgroundColor: Colors.grey[50],

        // Use Stack to overlay the sliding Nav Bar on top of the body
        body: Stack(
          children: [
            // 1. THE MAIN CONTENT
            // It fills the whole screen
            Positioned.fill(child: screens[_page]),

            // 2. THE SLIDING NAV BAR
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              // If visible: sits at bottom (0).
              // If hidden: slides down by 100px (off screen).
              bottom: _isBottomNavVisible ? 0 : -120,

              child: SafeArea(
                top: false,
                // We maintain bottom padding so it looks good on iPhone X etc.
                maintainBottomViewPadding: true,
                child: CurvedNavigationBar(
                  key: _bottomNavigationKey,
                  index: 0,
                  height: 60.0, // Fixed height for the bar itself
                  color: AppColors.primary,
                  buttonBackgroundColor: AppColors.primary,
                  backgroundColor:
                      Colors.transparent, // Allows body to show through curve
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 400),
                  items: <Widget>[
                    Icon(Icons.home_outlined, size: 30, color: Colors.white),
                    Icon(Icons.search, size: 30, color: Colors.white),
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
                      _isBottomNavVisible = true; // Always show when tapping
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
