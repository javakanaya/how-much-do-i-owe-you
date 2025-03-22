// ui/screens/settlement/widgets/settlement_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/status_badge.dart';

class SettlementDetailsHeader extends StatelessWidget {
  final SettlementModel settlement;

  const SettlementDetailsHeader({super.key, required this.settlement});

  @override
  Widget build(BuildContext context) {
    // Currency formatter for Rupiah
    final rupiahFormat = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: AppConstants.currencyDecimalDigits,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge and date
        Row(
          children: [
            StatusBadge(status: settlement.status),
            const Spacer(),
            Text(
              DateFormat(
                AppConstants.dateTimeFormatDisplay,
              ).format(settlement.date),
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Settlement ID
        const Text(
          'Settlement ID',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),

        const SizedBox(height: 4),

        Text(
          settlement.settlementId,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Total amount
        const Text(
          'Total Amount',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),

        const SizedBox(height: 4),

        Text(
          rupiahFormat.format(settlement.amount),
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
