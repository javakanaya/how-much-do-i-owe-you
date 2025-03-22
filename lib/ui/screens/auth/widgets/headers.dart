import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/app_logo.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/screen_header.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenHeader(
      title: 'How Much Do I Owe You?',
      subtitle: 'Track shared expenses with friends',
      icon: AppLogo(),
    );
  }
}

class PasswordResetHeader extends StatelessWidget {
  const PasswordResetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenHeader(
      title: 'Forgot your password?',
      subtitle:
          'Enter your email address and we\'ll send you instructions to reset your password.',
      icon: Icon(
        Icons.lock_reset,
        size: 64,
        color: AppTheme.primaryColor,
      ),
    );
  }
}
