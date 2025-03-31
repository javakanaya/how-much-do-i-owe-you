import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/login_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/home_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Authentication error: $e'),
    );
  }
}
