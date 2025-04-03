import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
              return Text("User Data");
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
