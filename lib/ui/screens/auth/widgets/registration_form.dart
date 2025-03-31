import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/utils/form_validators.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/auth_error_display.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/password_input_field.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';

class RegistrationForm extends ConsumerStatefulWidget {
  final Future<void> Function(String email, String password, String name) onRegister;
  final bool isLoading;

  const RegistrationForm({super.key, required this.onRegister, required this.isLoading});

  @override
  ConsumerState<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends ConsumerState<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthErrorDisplay(),

          CustomInputField(
            controller: _nameController,
            labelText: "Fullname",
            hintText: "Enter your fullname",
            prefixIcon: Icons.person_outline,
            validator: FormValidators.validateName,
          ),

          SizedBox(height: 16),

          CustomInputField(
            controller: _emailController,
            labelText: "Email",
            hintText: "Enter your email",
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
          ),
          SizedBox(height: 16),

          PasswordInputField(
            controller: _passwordController,
            validator: FormValidators.validatePassword,
          ),

          SizedBox(height: 16),

          PasswordInputField(
            controller: _confirmPasswordController,
            labelText: "Confirm Password",
            hintText: "Confirm your password",
            validator:
                (value) => FormValidators.validateConfirmPassword(
                  value,
                  _passwordController.text,
                ),
          ),

          SizedBox(height: 24),

          PrimaryButton(
            text: "Create Account",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onRegister(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                  _nameController.text.trim(),
                );
              }
            },
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
