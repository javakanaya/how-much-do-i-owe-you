import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String? profileImageUrl;
  final String userName;

  // This widget is used to display the profile header in the profile screen
  const ProfileHeader({super.key, required this.profileImageUrl, required this.userName});

  @override
  Widget build(BuildContext context) {
    // Profile Headerp
    return Column(
      children: [
        // Profile Image
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryColor.withAlpha(25),
            border: Border.all(color: AppTheme.primaryColor.withAlpha(124), width: 2),
          ),
          child:
              profileImageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                  ) // Placeholder for image loading
                  : const Icon(Icons.person, size: 60, color: AppTheme.primaryColor),
        ),

        const SizedBox(height: 16),

        // Display Name
        Text(userName, style: AppTheme.h1Style),

        // Edit profile Button
        TextButton.icon(
          onPressed: () {
            // Clear any existing Snackbar before showing a new one
            ScaffoldMessenger.of(context).removeCurrentSnackBar();

            // TODO: Navigate to edit profile screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Profile feature coming soon')),
            );
          },
          icon: const Icon(Icons.edit, color: AppTheme.primaryColor, size: 16),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}
