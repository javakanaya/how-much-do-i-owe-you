import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/ui/screens/profile/widgets/info_row.dart';
import 'package:intl/intl.dart';

class UserInfo extends StatelessWidget {
  final UserModel user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 16),

            InfoRow(icon: Icons.email_outlined, title: 'Email', value: user.email),

            const SizedBox(height: 24),

            InfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Joined',
              value: DateFormat('dd MMMM yyyy').format(user.createdAt),
            ),

            const Divider(height: 24),

            InfoRow(
              icon: Icons.access_time_outlined,
              title: 'Last Active',
              value: DateFormat('dd MMMM yyyy, HH:mm').format(user.lastActive),
            ),
          ],
        ),
      ),
    );
  }
}
