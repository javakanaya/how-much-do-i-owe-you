// ui/screens/settlement/widgets/transaction_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final bool isSelected;
  final VoidCallback onToggle;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Currency formatter for Rupiah
    final rupiahFormat = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: AppConstants.currencyDecimalDigits,
    );

    return CheckboxListTile(
      value: isSelected,
      onChanged: (_) => onToggle(),
      activeColor: AppTheme.primaryColor,
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        DateFormat(AppConstants.dateFormatDisplay).format(transaction.date),
      ),
      secondary: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          rupiahFormat.format(transaction.amount),
          style: const TextStyle(
            color: AppTheme.errorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
