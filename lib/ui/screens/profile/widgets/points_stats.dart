import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class PointsStats extends StatelessWidget {
  final int points;

  const PointsStats({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Points', style: AppTheme.bodySecondaryStyle),
                    Text('$points pts', style: AppTheme.h2Style),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Earn points by creating transactions and settling debts!',
              style: AppTheme.captionStyle,
            ),
          ],
        ),
      ),
    );
  }
}
