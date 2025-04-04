import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';
import 'package:intl/intl.dart';

class TransactionDetailCard extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionDetailCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final isCurrentUserPayer = transaction.payerId == currentUserAsync?.uid;
    final currentUserParticipation = transaction.participants.firstWhere(
      (p) => p.userId == currentUserAsync?.uid,
    );

    // final payerUserDataAsync = ref.watch(userDataProvider(transaction.payerId));
    final payerUserDataAsync = ref.watch(dummyUserDataProvider(transaction.payerId));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: payerUserDataAsync.when(
          data: (payerUserData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payer name and role
                Row(
                  children: [
                    // Payer Avatar
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withAlpha(51),
                      radius: 20,
                      child:
                          payerUserData!.photoURL != null
                              ? CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(payerUserData.photoURL!),
                              )
                              : Text(
                                _getInitials(payerUserData.displayName),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),

                    const SizedBox(width: 12),

                    // Payer name and role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrentUserPayer
                                ? 'You paid'
                                : '${payerUserData.displayName} paid',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Total amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      AppConstants.rupiahFormat.format(transaction.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),

                const Divider(height: 32, color: AppTheme.dividerColor),

                // Current user's share
                if (currentUserParticipation.isPayer) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withAlpha(51),
                        radius: 20,
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You are owed by others',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${_getSettledCount(transaction.participants)} of ${transaction.participants.length - 1} people have settled',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppConstants.rupiahFormat.format(
                          transaction.participants
                              .where((p) => !p.isPayer)
                              .fold<double>(0, (sum, p) => sum + p.owedAmount),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // User owes money
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            currentUserParticipation.isSettled
                                ? AppTheme.backgroundColor
                                : AppTheme.errorColor.withAlpha(51),
                        radius: 20,
                        child: Icon(
                          currentUserParticipation.isSettled
                              ? Icons.check_circle
                              : Icons.account_balance_wallet,
                          color:
                              currentUserParticipation.isSettled
                                  ? AppTheme.secondaryColor
                                  : AppTheme.errorColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUserParticipation.isSettled ? 'You paid' : 'You owe',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              currentUserParticipation.isSettled
                                  ? 'Settled on ${_getSettlementDate(currentUserParticipation)}'
                                  : 'Your share of the expense',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppConstants.rupiahFormat.format(
                          currentUserParticipation.owedAmount,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              currentUserParticipation.isSettled
                                  ? AppTheme.secondaryColor
                                  : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) =>
                  Center(child: Text('Error loading transactiondata: $error')),
        ),
      ),
    );
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1 && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Helper method to get the number of settled participants
  int _getSettledCount(List<dynamic> participants) {
    return participants.where((p) => p.isSettled).length - 1; // Subtract payer
  }

  // Helper method to get formatted settlement date
  String _getSettlementDate(dynamic participant) {
    if (participant.settledAt == null) return 'Unknown date';
    return DateFormat('d MMM yyyy').format(participant.settledAt);
  }
}
