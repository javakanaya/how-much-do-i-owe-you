import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/utils/form_validators.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/headers.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/password_input_field.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // clear any existing error
    ref.read(authErrorProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider.notifier);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      ref.read(authErrorProvider.notifier).setError(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {}

  void _navigateToPasswordReset() {}

  @override
  Widget build(BuildContext context) {
    final authError = ref.watch(authErrorProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo and Title
                    const LoginHeader(),
                    const SizedBox(height: 48),

                    // Error message if any,
                    if (authError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            authError,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // Email Field
                    CustomInputField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    PasswordInputField(
                      controller: _passwordController,
                      validator: FormValidators.validatePassword,
                    ),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _navigateToPasswordReset,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    PrimaryButton(
                      text: 'Login',
                      onPressed: _login,
                      isLoading: _isLoading,
                    ),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppTheme.textSecondaryColor),
                        ),
                        GestureDetector(
                          onTap: _navigateToRegister,
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
