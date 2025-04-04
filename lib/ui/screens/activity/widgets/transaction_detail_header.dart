import 'package:flutter/widgets.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class TransactionDetailHeader extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailHeader({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Indicator
        Row(
          children: [
            StatusBadge(status: transaction.status),
            const Spacer(),
            Text(
              DateFormat(AppConstants.dateFormatDisplay).format(transaction.date),
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Transaction description
        Text(
          transaction.description,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        // Total amount
        Text(
          AppConstants.rupiahFormat.format(transaction.amount),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
