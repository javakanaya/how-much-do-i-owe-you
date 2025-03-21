import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/utils/form_validators.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/headers.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({Key? key}) : super(key: key);

  @override
  State<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Here you would typically send a password reset email with Firebase
      // For now, we'll just simulate a delay and success
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
          _resetEmailSent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child:
              _resetEmailSent
                  ? _buildSuccessView(context)
                  : _buildResetForm(context),
        ),
      ),
    );
  }

  Widget _buildResetForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section with instructions
          const PasswordResetHeader(),
          const SizedBox(height: 32),

          // Email Field
          CustomInputField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
          ),

          const SizedBox(height: 32),

          // Reset Button
          PrimaryButton(
            text: 'Reset Password',
            onPressed: _resetPassword,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          // Back to Login link
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Login'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF757575),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Color(0xFF2ED573), // Green from your design
        ),
        const SizedBox(height: 24),
        const Text(
          'Check your email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We sent a password reset link to\n${_emailController.text}',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF757575),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Check your inbox and follow the instructions to reset your password.',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Didn't receive email button
        TextButton(
          onPressed: () {
            // Resend email logic would go here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reset email resent')),
            );
          },
          child: const Text(
            'Didn\'t receive the email? Send again',
            style: TextStyle(
              color: Color(0xFF2176FF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Return to Login Button
        PrimaryButton(
          text: 'Return to Login',
          onPressed: () => Navigator.pop(context),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
