// ui/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    try {
      setState(() {
        _isLoggingOut = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      // No need to navigate - the app router will handle redirection based on auth state
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.settingsRoute);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile photo and name
              _buildProfileHeader(user?.photoURL, user?.displayName ?? 'User'),

              const SizedBox(height: 32),

              // User info
              _buildUserInfoSection(user),

              const SizedBox(height: 32),

              // Stats section
              _buildStatsSection(user?.totalPoints ?? 0),

              const SizedBox(height: 32),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Logout',
                  icon: Icons.logout,
                  onPressed: _isLoggingOut ? () {} : _logout,
                  isLoading: _isLoggingOut,
                ),
              ),

              const SizedBox(height: 16),

              // App version
              Text(
                'Version ${AppConstants.appVersion}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile tab
        onTap: (index) {
          if (index == 0) {
            // Navigate to Home
            Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
          } else if (index == 1) {
            // Navigate to Activity
            Navigator.pushReplacementNamed(context, AppConstants.activityRoute);
          }
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

  Widget _buildProfileHeader(String? photoURL, String displayName) {
    return Column(
      children: [
        // Profile photo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          child:
              photoURL != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      photoURL,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  )
                  : const Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
        ),

        const SizedBox(height: 16),

        // Display name
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),

        // Edit profile button
        TextButton.icon(
          onPressed: () {
            // TODO: Navigate to edit profile screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit profile feature coming soon!'),
              ),
            );
          },
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection(dynamic user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Email
            _buildInfoRow(
              icon: Icons.email_outlined,
              title: 'Email',
              value: user?.email ?? 'Not available',
            ),

            const Divider(height: 24),

            // Join date
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Joined',
              value:
                  user?.createdAt != null
                      ? DateFormat('dd MMMM yyyy').format(user!.createdAt)
                      : 'Not available',
            ),

            const Divider(height: 24),

            // Last active
            _buildInfoRow(
              icon: Icons.access_time_outlined,
              title: 'Last Active',
              value:
                  user?.lastActive != null
                      ? DateFormat(
                        'dd MMMM yyyy, HH:mm',
                      ).format(user!.lastActive)
                      : 'Not available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(int points) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Points row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Text(
                        '$points pts',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
