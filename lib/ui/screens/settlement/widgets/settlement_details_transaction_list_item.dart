// ui/screens/settlement/widgets/transaction_list_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';

class SettlementDetailsTransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const SettlementDetailsTransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    // Currency formatter for Rupiah
    final rupiahFormat = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: AppConstants.currencyDecimalDigits,
    );

    return ListTile(
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        DateFormat(AppConstants.dateFormatDisplay).format(transaction.date),
      ),
      trailing: Text(
        rupiahFormat.format(transaction.amount),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      onTap: () {
        // Navigate to transaction detail
        Navigator.pushNamed(
          context,
          AppConstants.transactionDetailRoute,
          arguments: transaction.transactionId,
        );
      },
    );
  }
}
