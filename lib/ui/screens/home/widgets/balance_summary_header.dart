import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class BalanceSummaryHeader extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const BalanceSummaryHeader({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        Text(
          AppConstants.rupiahFormat.format(amount),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
