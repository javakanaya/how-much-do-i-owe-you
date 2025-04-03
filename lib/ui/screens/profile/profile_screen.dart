import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/profile/widgets/points_stats.dart';
import 'package:how_much_do_i_owe_you/ui/screens/profile/widgets/profile_header.dart';
import 'package:how_much_do_i_owe_you/ui/screens/profile/widgets/user_info.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/app_version.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  // Confirm and sign out function
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    // After awaiting the dialog (async gap), we need to check if the context is still valid
    // context.mounted ensures the BuildContext's associated State object hasn't been disposed
    // This prevents "setState() called after dispose()" errors that could occur if the user
    // navigated away while the dialog was open
    if (confirm == true && context.mounted) {
      await _signOut(context, ref);
    }
  }

  // Logout function that uses the auth provider
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      // Show a loading indicator or disable the button
      // Since we're using a stateless widget, we'd handle this through the UI
      // component itself or through a state provider if needed

      // Call the sign out method from the auth provider
      await ref.read(authServiceProvider.notifier).signOut();

      // The navigation will be handled by the auth state listener
      // No need to navigate manually
    } catch (e) {
      // Only show error message if the widget is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Column(
      children: [
        // App Bar Equivalent
        AppBar(title: const Text('Profile')),

        // Body Content
        Expanded(
          child: userDataAsync.when(
            data: (userData) {
              if (userData == null) {
                // Handle the case when user data is null
                // You can show a message or a placeholder widget
                return const Center(child: Text('User data not found'));
              }

              // profile screen content
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProfileHeader(
                      profileImageUrl: userData.photoURL,
                      userName: userData.displayName,
                    ),

                    const SizedBox(height: 32),

                    UserInfo(user: userData),

                    const SizedBox(height: 32),

                    PointsStats(points: userData.totalPoints),

                    const SizedBox(height: 32),

                    PrimaryButton(
                      text: "Logout",
                      onPressed: () => _confirmSignOut(context, ref),
                    ),

                    const SizedBox(height: 32),

                    AppVersion(),
                  ],
                ),
              );
            },

            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(child: Text('Error loading user data: $error')),
          ),
        ),
      ],
    );
  }
}
