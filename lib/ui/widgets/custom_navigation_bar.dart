// ui/widgets/custom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/home_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/activity_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/profile/profile_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  final int selectedPageIndex;

  const CustomNavigationBar({super.key, this.selectedPageIndex = 0});

  @override
  State<CustomNavigationBar> createState() => CustomNavigationBarState();
}

class CustomNavigationBarState extends State<CustomNavigationBar> {
  late int _selectedPageIndex;

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
  }

  // List of screen widgets
  final List<Widget> _screens = const [
    HomeScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

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
