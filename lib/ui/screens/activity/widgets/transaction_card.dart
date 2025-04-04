import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/transaction_detail_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/payer_name_widget.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class TransactionCard extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isUserPayer = transaction.payerId == currentUser!.uid;

    final currentUserParticipantData = transaction.participants.firstWhere(
      (p) => p.userId == currentUser.uid,
      orElse:
          () => TransactionParticipant(
            userId: currentUser.uid,
            owedAmount: 0,
            isPayer: isUserPayer,
            isSettled: false,
          ),
    );

    // Calculate the amount relevant to current user
    double relevantAmount = 0.0;
    String directionText = '';

    if (isUserPayer) {
      // Total amount minus the user's share
      relevantAmount = transaction.amount - currentUserParticipantData.owedAmount;
      directionText = 'you paid for others';
    } else {
      relevantAmount = currentUserParticipantData.owedAmount;
      directionText = 'you are owed';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TransactionDetailScreen(transactionId: transaction.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction description
                        Text(
                          transaction.description,
                          style: AppTheme.h2Style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // payer
                        if (!isUserPayer) PayerNameWidget(payerId: transaction.payerId),

                        const SizedBox(height: 4),

                        Text(
                          DateFormat(
                            AppConstants.dateFormatDisplay,
                          ).format(transaction.date),
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                  ),

                  StatusBadge(status: transaction.status),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(directionText, style: AppTheme.bodySecondaryStyle),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.rupiahFormat.format(relevantAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUserPayer ? AppTheme.primaryColor : AppTheme.errorColor,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
