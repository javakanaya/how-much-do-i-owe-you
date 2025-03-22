// ui/screens/dashboard/widgets/balance_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/balance_provider.dart';

class BalanceSummaryWidget extends StatelessWidget {
  final BalanceProvider balanceProvider;

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  BalanceSummaryWidget({super.key, required this.balanceProvider});

  @override
  Widget build(BuildContext context) {
    // Determine balance state and appropriate colors
    final balanceStatus = balanceProvider.getTotalBalanceStatus();
    final isSettled = balanceStatus == BalanceStatus.zero;

    // Set colors based on balance status
    final Color textColor;
    final Color backgroundColor;
    final Color borderColor;
    final String balanceText;

    switch (balanceStatus) {
      case BalanceStatus.positive:
        // Positive means others owe you money (good for you)
        textColor = AppTheme.secondaryColor; // Green for money coming in
        backgroundColor = const Color(0xFFE6F4EA); // Light green background
        borderColor = AppTheme.secondaryColor;
        balanceText = 'you are owed';
        break;
      case BalanceStatus.negative:
        // Negative means you owe others money
        textColor = AppTheme.errorColor; // Red for money going out
        backgroundColor = const Color(0xFFFCE8E8); // Light red background
        borderColor = AppTheme.errorColor;
        balanceText = 'you owe';
        break;
      case BalanceStatus.zero:
        // All settled up
        textColor = const Color(0xFF757575); // Neutral gray
        backgroundColor = const Color(0xFFF5F5F5); // Light gray background
        borderColor = const Color(0xFFDEDEDE);
        balanceText = 'all settled up';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!isSettled) ...[
                Text(
                  rupiahFormat.format(balanceProvider.totalBalance.abs()),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                balanceText,
                style: TextStyle(
                  fontSize: isSettled ? 20 : 14,
                  fontWeight: isSettled ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (!isSettled) ...[
            const SizedBox(height: 12),
            // Add a tip or action prompt based on status
            Row(
              children: [
                Icon(
                  balanceStatus == BalanceStatus.positive
                      ? Icons.info_outline
                      : Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: textColor.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  balanceStatus == BalanceStatus.positive
                      ? 'Tap to see who owes you'
                      : 'Tap to settle up',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
