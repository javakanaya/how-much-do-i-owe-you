// ui/screens/home/widgets/person_balance_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/person_balance_model.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/settlement_creation_screen.dart';

class PersonBalanceCard extends StatelessWidget {
  final PersonBalance balance;

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  PersonBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    // Determine colors based on whether we owe them or they owe us
    final bool weOweThem = !balance.isPositive;
    final Color primaryColor =
        weOweThem ? AppTheme.errorColor : AppTheme.primaryColor;
    final Color lightColor =
        weOweThem
            ? const Color(0xFFFCE8E8) // Light red
            : const Color(0xFFE6F0FF); // Light blue

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to transaction history or detail with this person
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User info and amount
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: balance.avatarColor,
                    radius: 24,
                    child: Text(
                      balance.initials,
                      style: TextStyle(
                        color: balance.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // User name and transaction count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balance.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${balance.transactionCount} transaction${balance.transactionCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        balance.getFormattedBalance(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        weOweThem ? 'you owe' : 'owes you',
                        style: TextStyle(color: primaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Settle Up button (only show if we owe them)
              if (weOweThem)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to settlement screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SettlementCreationScreen(
                                userId: balance.userId, // javakanaya
                                userName: balance.name,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Settle Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightColor,
                      foregroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
