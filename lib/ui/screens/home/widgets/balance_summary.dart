import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/balance_model.dart';
import 'package:how_much_do_i_owe_you/providers/balance_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/all_settled_up_card.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/balance_item.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/balance_summary_error.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/balance_summary_header.dart';

class BalanceSummary extends ConsumerWidget {
  const BalanceSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesDataAsync = ref.watch(balanceDataProvider);

    return balancesDataAsync.when(
      data: (balances) {
        final List<BalanceModel> youOwe = [];
        final List<BalanceModel> owedToYou = [];

        for (var balance in balances) {
          if (balance.amount < 0) {
            youOwe.add(balance);
          } else if (balance.amount > 0) {
            owedToYou.add(balance);
          }
          // Skip balances with amount = 0
        }

        // Check if we have any balances to show
        final bool hasBalances = youOwe.isNotEmpty || owedToYou.isNotEmpty;

        // Show "all settled up" message
        if (!hasBalances) {
          return AllSettledUpCard();
        }

        final double totalYouOwe = youOwe.fold(
          0.0,
          (sum, balance) => sum + balance.amount.abs(),
        );
        final double totalOwedToYou = owedToYou.fold(
          0.0,
          (sum, balance) => sum + balance.amount,
        );

        return Column(
          children: [
            // Title for the section
            const Text(
              'Your Balances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // "You owe" section (if applicable)
            // spread operator to unpack the list
            if (youOwe.isNotEmpty) ...[
              BalanceSummaryHeader(
                title: 'You owe',
                amount: totalYouOwe,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 8),
              ...youOwe.map((balance) => BalanceItem(balance: balance, isDebt: true)),
            ],

            // "Owed to you" section (if applicable)
            // spread operator to unpack the list
            if (owedToYou.isNotEmpty) ...[
              BalanceSummaryHeader(
                title: 'Owed to you',
                amount: totalOwedToYou,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: 8),
              ...owedToYou.map((balance) => BalanceItem(balance: balance, isDebt: false)),
            ],
          ],
        );
      },
      loading:
          () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (err, stack) => BalanceSummaryError(error: err),
    );
  }
}
