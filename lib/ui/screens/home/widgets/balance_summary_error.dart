import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class BalanceSummaryError extends StatelessWidget {
  final Object error;
  const BalanceSummaryError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withAlpha(13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.errorColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Error Loading Balances',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load your balance data:\n$error',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}
