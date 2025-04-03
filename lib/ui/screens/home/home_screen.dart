import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Column(
      children: [
        // App Bar Equivalent
        AppBar(title: const Text('Home')),

        // Body Content
        Expanded(
          child: userDataAsync.when(
            data: (userData) {
              if (userData == null) {
                return const Center(child: Text('No user data available.'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${userData.displayName}!',
                              style: AppTheme.subheadingStyle,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'You have ${userData.totalPoints} points.',
                              style: AppTheme.captionStyle,
                            ),
                          ],
                        ),
                      ),
                    ),
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
