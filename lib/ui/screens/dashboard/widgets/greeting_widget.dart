// ui/widgets/home/greeting_widget.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class GreetingWidget extends StatelessWidget {
  final UserModel? user;

  const GreetingWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${user?.displayName ?? 'there'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const Text(
              'Let\'s manage expenses together!',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),

        // Points badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E0),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFFFD700)),
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${user?.totalPoints ?? 350} pts',
                style: const TextStyle(fontSize: 11, color: Color(0xFF7D6E00)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
