import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/utils/form_validators.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/password_input_field.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/profile_image_picker.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'dart:io';
import '../../../config/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onProfileImageSelected(File? image) {
    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _displayNameController.text.trim(),
        _profileImage,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Please log in with your credentials',
            ),
            backgroundColor: AppTheme.secondaryColor,
            duration: Duration(seconds: 5),
          ),
        );

        // Sign out to clear any auth state
        await authProvider.signOut();

        // Navigate back to login screen
        Navigator.of(context).pushReplacementNamed('/');
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } else if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms of service')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildRegistrationForm(isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Picture
          ProfileImagePickerSection(
            profileImage: _profileImage,
            displayName: _displayNameController.text,
            onImageSelected: _onProfileImageSelected,
          ),

          const SizedBox(height: 32),

          // Display Name Field
          CustomInputField(
            controller: _displayNameController,
            labelText: 'Display Name',
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: FormValidators.validateName,
            onChanged: (_) {
              if (_profileImage == null) {
                setState(() {});
              }
            },
          ),

          const SizedBox(height: 16),

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
            labelText: 'Password',
            hintText: 'Create a password',
            validator: FormValidators.validatePassword,
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          PasswordInputField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            validator:
                (value) => FormValidators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
          ),

          const SizedBox(height: 24),

          // Terms of Service Checkbox
          _buildTermsCheckbox(),

          const SizedBox(height: 32),

          // Register Button
          PrimaryButton(
            text: 'Create Account',
            onPressed: _register,
            isLoading: isLoading,
          ),

          const SizedBox(height: 24),

          // Already have an account link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Login',
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
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptedTerms = !_acceptedTerms;
              });
            },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
