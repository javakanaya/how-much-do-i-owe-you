// ui/screens/settlement/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'completed':
        bgColor = AppTheme.secondaryColor.withOpacity(0.2);
        textColor = AppTheme.secondaryColor;
        label = 'Completed';
        break;
      case 'canceled':
        bgColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        label = 'Canceled';
        break;
      case 'pending':
        bgColor = Colors.amber.withOpacity(0.2);
        textColor = Colors.amber.shade900;
        label = 'Pending';
        break;
      default:
        bgColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
