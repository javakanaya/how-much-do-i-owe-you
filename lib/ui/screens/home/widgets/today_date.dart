import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:intl/intl.dart';

class TodayDate extends StatelessWidget {
  const TodayDate({super.key});

  @override
  Widget build(BuildContext context) {
    // Get today's date
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');
    final formattedDate = dateFormat.format(now);

    return Text(
      formattedDate,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }
}
