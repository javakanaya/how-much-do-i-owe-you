import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.bodySecondaryStyle),
              Text(value, style: AppTheme.bodyStyle),
            ],
          ),
        ),
      ],
    );
  }
}
