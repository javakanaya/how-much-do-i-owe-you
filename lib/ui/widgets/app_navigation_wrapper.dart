import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/activity_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/home_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/profile/profile_screen.dart';

class AppNavigationWrapper extends StatefulWidget {
  final int initialPageIndex;

  const AppNavigationWrapper({super.key, this.initialPageIndex = 0});

  @override
  State<AppNavigationWrapper> createState() => _AppNavigationWrapperState();
}

class _AppNavigationWrapperState extends State<AppNavigationWrapper> {
  // The 'late' keyword allows declaring a non-nullable variable that will be
  // initialized before use, but not at declaration time. This lets us use the
  // widget parameter in initState() while keeping type safety without null checks.
  // This variable tracks which navigation tab is currently selected.
  late int _selectedPageIndex;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.initialPageIndex;
  }

  // List of screen widgets
  final List<Widget> _screens = const [HomeScreen(), ActivityScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
