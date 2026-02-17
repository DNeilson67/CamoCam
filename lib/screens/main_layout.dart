import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'home/home_screen.dart';
import 'pattern_generator/pattern_generator_landing_screen.dart';
import 'ar/ar_choose_model_screen.dart';
import 'tryons/tryon_choose_model_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<IconData> _iconList = [
    Icons.home,
    Icons.view_in_ar_outlined,
    Icons.checkroom_outlined,
    Icons.person_outline,
  ];

  // Screens for each nav item
  List<Widget> get _screens => [
    HomeScreenContent(
      onNavigateToPatternGenerator: () {
        setState(() {
          _selectedIndex = 4;
        });
      },
    ), // Home content without navbar
    const ArChooseModelScreen(), // AR Screen
    const TryonChooseModelScreen(), // Try-ons Screen
    const ProfileScreen(), // Profile Screen
    const PatternGeneratorLandingScreen(), // Pattern Generator
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFABTapped() {
    // Switch to Pattern Generator screen (index 4)
    setState(() {
      _selectedIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFABTapped,
        backgroundColor: const Color(0xFF4A7C59),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.auto_awesome, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: _onNavItemTapped,
        activeColor: const Color(0xFF4A7C59),
        inactiveColor: const Color(0xFF1A1A1A),
        backgroundColor: Colors.white,
        splashColor: const Color(0xFF4A7C59).withOpacity(0.1),
        splashSpeedInMilliseconds: 300,
        iconSize: 24,
        height: 60,
        elevation: 8,
      ),
    );
  }
}
