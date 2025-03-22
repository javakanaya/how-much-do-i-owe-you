// ui/screens/settlement/widgets/settlement_transaction_list.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/transaction_item.dart';

class SettlementCreationTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Set<String> selectedTransactionIds;
  final bool allTransactionsSelected;
  final Function(String) onToggleTransaction;
  final VoidCallback onToggleAllTransactions;

  const SettlementCreationTransactionList({
    super.key,
    required this.transactions,
    required this.selectedTransactionIds,
    required this.allTransactionsSelected,
    required this.onToggleTransaction,
    required this.onToggleAllTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // "Select All" option
        ListTile(
          leading: Checkbox(
            value: allTransactionsSelected,
            onChanged: (_) => onToggleAllTransactions(),
            activeColor: AppTheme.primaryColor,
          ),
          title: const Text(
            'Select All Transactions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: onToggleAllTransactions,
        ),
        const Divider(height: 1),

        // Transactions
        Expanded(
          child: ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isSelected = selectedTransactionIds.contains(
                transaction.transactionId,
              );

              return TransactionItem(
                transaction: transaction,
                isSelected: isSelected,
                onToggle: () => onToggleTransaction(transaction.transactionId),
              );
            },
          ),
        ),
      ],
    );
  }
}
