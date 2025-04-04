import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/payer_name_widget.dart';
import 'package:intl/intl.dart';

class TransactionCard extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionCard({super.key, required this.transaction});

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'settled':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.infoColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isUserPayer = transaction.payerId == currentUser!.uid;
    final statusColor = _getStatusColor();

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
      directionText = 'You paid';
    } else {
      relevantAmount = currentUserParticipantData.owedAmount;
      directionText = 'you are owed';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // payer
                        if (!isUserPayer) PayerNameWidget(payerId: transaction.payerId),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(AppConstants.dateFormatDisplay).format(transaction.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        directionText,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isUserPayer ? AppTheme.primaryColor : AppTheme.warningColor,
                        ),
                      ),
                      Text(
                        AppConstants.rupiahFormat.format(relevantAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              isUserPayer ? AppTheme.primaryColor : AppTheme.warningColor,
                        ),
                      ),
                    ],
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
