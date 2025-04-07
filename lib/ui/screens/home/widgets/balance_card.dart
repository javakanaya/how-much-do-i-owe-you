import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';

class BalanceCard extends ConsumerWidget {
  final BalanceModel balance;
  final bool isDebt;
  final VoidCallback onTap;
  final VoidCallback onSettleUp;

  const BalanceCard({
    super.key,
    required this.isDebt,
    required this.balance,
    required this.onTap,
    required this.onSettleUp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    final otherUserId =
        balance.userIdA == currentUser?.uid ? balance.userIdB : balance.userIdA;

    final otherUserDataAsync = ref.watch(userDataProvider(otherUserId));

    final Color amountColor = !isDebt ? AppTheme.successColor : AppTheme.errorColor;
    final IconData directionIcon = !isDebt ? Icons.arrow_downward : Icons.arrow_upward;
    final Color iconBackgroundColor =
        !isDebt ? AppTheme.successColor.withAlpha(25) : AppTheme.errorColor.withAlpha(25);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Direction icon with colored background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(directionIcon, color: amountColor, size: 24),
              ),

              const SizedBox(width: 16),

              // Person name and amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    otherUserDataAsync.when(
                      data:
                          (otherUserData) =>
                              Text(otherUserData!.displayName, style: AppTheme.bodyStyle),
                      loading: () => const Text('Loading...', style: AppTheme.bodyStyle),
                      error:
                          (_, __) =>
                              const Text('Unknown User', style: AppTheme.bodyStyle),
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                AppConstants.rupiahFormat.format(balance.amount.abs()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
