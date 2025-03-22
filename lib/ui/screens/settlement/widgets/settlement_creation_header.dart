// ui/screens/settlement/widgets/settlement_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class SettlementCreationHeader extends StatelessWidget {
  final String userName;
  final double totalAmount;

  const SettlementCreationHeader({
    super.key,
    required this.userName,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Currency formatter for Rupiah
    final rupiahFormat = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: AppConstants.currencyDecimalDigits,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Amount to Settle',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            rupiahFormat.format(totalAmount),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select which transactions to settle with $userName:',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
