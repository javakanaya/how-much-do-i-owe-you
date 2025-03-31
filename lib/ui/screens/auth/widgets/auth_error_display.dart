import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';

class AuthErrorDisplay extends ConsumerWidget {
  const AuthErrorDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authError = ref.watch(authErrorProvider);

    if (authError == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          authError,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
