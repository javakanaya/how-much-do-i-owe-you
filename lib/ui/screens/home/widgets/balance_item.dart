import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';

class BalanceItem extends ConsumerWidget {
  final BalanceModel balance;
  final bool isDebt;

  const BalanceItem({super.key, required this.balance, required this.isDebt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    final otherUserId =
        balance.userIdA == currentUser?.uid ? balance.userIdB : balance.userIdA;

    final otherUserAsyncValue = ref.watch(dummyUserDataProvider(otherUserId));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isDebt
                  ? AppTheme.errorColor.withAlpha(25)
                  : AppTheme.secondaryColor.withAlpha(25),
          child: Icon(
            isDebt ? Icons.arrow_upward : Icons.arrow_downward,
            color: isDebt ? AppTheme.errorColor : AppTheme.secondaryColor,
          ),
        ),
        title: otherUserAsyncValue.when(
          data:
              (userData) => Text(
                userData?.displayName ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Unknown User'),
        ),
        trailing: Text(
          AppConstants.rupiahFormat.format(balance.amount.abs()),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDebt ? AppTheme.errorColor : AppTheme.secondaryColor,
          ),
        ),
        onTap: () {
          // TODO: Implement the onTap functionality
          // Navigate to detailed balance screen or settlement screen
        },
      ),
    );
  }
}
