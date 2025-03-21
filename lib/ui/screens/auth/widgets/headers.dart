import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/widgets/app_logo.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final double spacing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[icon!, SizedBox(height: spacing)],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

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
        color: Color(0xFF2176FF),
      ),
    );
  }
}
