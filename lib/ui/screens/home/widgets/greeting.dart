// ui/widgets/home/greeting_widget.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class Greeting extends StatelessWidget {
  final UserModel user;

  const Greeting({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${user.displayName}', style: AppTheme.h2Style),
            const SizedBox(height: 4),
            Text('Let\'s manage expenses together!', style: AppTheme.bodySecondaryStyle),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withAlpha(51),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: AppTheme.warningColor, size: 18),
              const SizedBox(width: 4),
              Text(
                '${user.totalPoints} pts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.warningColor,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
