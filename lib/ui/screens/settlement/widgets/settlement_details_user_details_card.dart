// ui/screens/settlement/widgets/user_details_card.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/user_info_row.dart';

class SettlementDetailsUserDetailsCard extends StatelessWidget {
  final UserModel? payer;
  final UserModel? receiver;
  final bool isUserPayer;

  const SettlementDetailsUserDetailsCard({
    super.key,
    required this.payer,
    required this.receiver,
    required this.isUserPayer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settlement Between',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Payer details
            UserInfoRow(
              user: payer,
              avatarColor: AppTheme.errorColor.withOpacity(0.1),
              avatarIcon: const Icon(
                Icons.arrow_upward,
                color: AppTheme.errorColor,
              ),
              displayName:
                  isUserPayer
                      ? 'You (Payer)'
                      : '${payer?.displayName ?? 'Unknown'} (Payer)',
              email: payer?.email,
            ),

            // Arrow
            Center(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Icon(Icons.arrow_downward, color: AppTheme.primaryColor),
              ),
            ),

            // Receiver details
            UserInfoRow(
              user: receiver,
              avatarColor: AppTheme.secondaryColor.withOpacity(0.1),
              avatarIcon: const Icon(
                Icons.arrow_downward,
                color: AppTheme.secondaryColor,
              ),
              displayName:
                  !isUserPayer
                      ? 'You (Receiver)'
                      : '${receiver?.displayName ?? 'Unknown'} (Receiver)',
              email: receiver?.email,
            ),
          ],
        ),
      ),
    );
  }
}
