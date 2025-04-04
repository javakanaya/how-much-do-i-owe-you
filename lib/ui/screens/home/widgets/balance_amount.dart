// lib/ui/widgets/balance_amount.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class BalanceAmount extends StatelessWidget {
  final double amount;
  final bool isOwed; // true if money is owed to user, false if user owes

  const BalanceAmount({super.key, required this.amount, required this.isOwed});

  @override
  Widget build(BuildContext context) {
    final formattedAmount = AppConstants.rupiahFormat.format(amount.abs());
    final color = isOwed ? AppTheme.successColor : AppTheme.errorColor;

    return Text(
      formattedAmount,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: AppTheme.fontFamily,
      ),
    );
  }
}
