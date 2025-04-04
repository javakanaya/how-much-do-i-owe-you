// lib/ui/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    TextStyle textStyle;

    switch (status.toLowerCase()) {
      case AppConstants.statusPending:
        backgroundColor = AppTheme.warningColor.withAlpha(31);
        textStyle = AppTheme.pendingStyle;
        break;
      case AppConstants.statusSettled:
        backgroundColor = AppTheme.successColor.withAlpha(31);
        textStyle = AppTheme.settledStyle;
        break;
      case AppConstants.statusCancelled:
        backgroundColor = AppTheme.errorColor.withAlpha(31);
        textStyle = AppTheme.errorStyle;
        break;
      default:
        backgroundColor = AppTheme.infoColor.withAlpha(31);
        textStyle = AppTheme.bodySecondaryStyle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: textStyle),
    );
  }
}
