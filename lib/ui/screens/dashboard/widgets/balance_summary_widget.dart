// ui/widgets/home/balance_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/balance_provider.dart';

class BalanceSummaryWidget extends StatelessWidget {
  final BalanceProvider balanceProvider;

  const BalanceSummaryWidget({super.key, required this.balanceProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(fontSize: 14, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$${balanceProvider.totalBalance.abs().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                balanceProvider.getTotalBalanceStatus() ==
                        BalanceStatus.positive
                    ? 'you are owed'
                    : balanceProvider.getTotalBalanceStatus() ==
                        BalanceStatus.negative
                    ? 'you owe'
                    : 'all settled up',
                style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
