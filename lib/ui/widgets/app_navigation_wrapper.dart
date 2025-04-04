import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
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

  static const List<Widget> _screens = [HomeScreen(), ActivityScreen(), ProfileScreen()];

  static const List<String> _appBarTitles = ['Home', 'Activity', 'Profile'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedPageIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
      ),
      body: _screens[_selectedPageIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
          currentIndex: _selectedPageIndex,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondaryColor,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
          ),
        ),
      ),
      floatingActionButton:
          _selectedPageIndex == 0 || _selectedPageIndex == 1
              ? FloatingActionButton(
                onPressed: () {
                  // Navigate to add transaction screen
                },
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
