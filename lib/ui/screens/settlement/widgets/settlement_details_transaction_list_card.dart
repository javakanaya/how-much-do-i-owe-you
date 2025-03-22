// ui/screens/settlement/widgets/transactions_list_card.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_details_transaction_list_item.dart';

class SettlementDetailsTransactionsListCard extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SettlementDetailsTransactionsListCard({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child:
              transactions.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    ),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return SettlementDetailsTransactionListItem(
                        transaction: transactions[index],
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
