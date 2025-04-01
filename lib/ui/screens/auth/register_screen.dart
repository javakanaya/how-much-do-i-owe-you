import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/registration_form.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _isLoading = false;

  @override
  void dispose() {
    ref.read(authErrorProvider.notifier).clearError();
    super.dispose();
  }

  Future<void> _register(String email, String password, String name) async {
    ref.read(authErrorProvider.notifier).clearError();

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    // Attempt to register
    final user = await ref
        .read(authServiceProvider.notifier)
        .createUserWithEmailAndPassword(email, password, name);

    if (ref.read(authErrorProvider) != null) {
      setState(() {
        _isLoading = false;
      });
    }

    // If registration is successful, pop back to allow AuthWrapper to handle navigation
    if (user != null && mounted) {
      Navigator.of(context).pop(); // Remove RegisterScreen from stack
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
        title: const Text(
          'Create Account',
          style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RegistrationForm(onRegister: _register, isLoading: _isLoading),
            ),
          ),
        ),
      ),
    );
  }
}
