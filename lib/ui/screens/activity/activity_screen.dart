import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/empty_transactions.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/transaction_list.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsDataAsync = ref.watch(userTransactionsProvider);

    return SafeArea(
      child: transactionsDataAsync.when(
        data: (transactionsData) {
          if (transactionsData.isEmpty) {
            return const EmptyTransactions();
          }

          return TransactionList(transactions: transactionsData);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading user data: $error')),
      ),
    );
  }
}
