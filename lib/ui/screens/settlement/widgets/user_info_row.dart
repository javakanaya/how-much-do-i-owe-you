// ui/screens/settlement/widgets/user_info_row.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';

class UserInfoRow extends StatelessWidget {
  final UserModel? user;
  final Color avatarColor;
  final Widget avatarIcon;
  final String displayName;
  final String? email;

  const UserInfoRow({
    super.key,
    required this.user,
    required this.avatarColor,
    required this.avatarIcon,
    required this.displayName,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          backgroundColor: avatarColor,
          radius: 20,
          child:
              user?.photoURL != null
                  ? CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(user!.photoURL!),
                  )
                  : avatarIcon,
        ),

        const SizedBox(width: 12),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (email != null)
                Text(
                  email!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
