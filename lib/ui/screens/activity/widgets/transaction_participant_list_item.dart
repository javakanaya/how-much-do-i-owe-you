import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';

class TransactionParticipantListItem extends ConsumerWidget {
  final TransactionParticipant participant;

  const TransactionParticipantListItem({super.key, required this.participant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use dummy data for development; switch to real data in production
    final userDataAsync = ref.watch(userDataProvider(participant.userId));
    final Color backgroundColor =
        participant.isPayer
            ? AppTheme.primaryColor.withAlpha(51)
            : participant.isSettled
            ? AppTheme.secondaryColor.withAlpha(51)
            : AppTheme.errorColor.withAlpha(51);

    final Color textColor =
        participant.isPayer
            ? AppTheme.primaryColor
            : participant.isSettled
            ? AppTheme.secondaryColor
            : AppTheme.errorColor;
    // Define colors based on participant status

    return userDataAsync.when(
      data: (userData) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: backgroundColor,
                radius: 20,
                child:
                    userData?.photoURL != null
                        ? CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(userData!.photoURL!),
                        )
                        : participant.isPayer
                        ? Text(
                          _getInitials(userData!.displayName),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        )
                        : Icon(
                          participant.isSettled
                              ? Icons.check_circle
                              : Icons.account_balance_wallet,
                          color: textColor,
                          size: 20,
                        ),
              ),

              const SizedBox(width: 12),

              // Name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData!.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _getParticipantStatus(),
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                AppConstants.rupiahFormat.format(participant.owedAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      error:
          (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.withAlpha(51),
                  radius: 20,
                  child: const Icon(Icons.error_outline, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Failed to load user",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Helper method to get the participant's status text
  String _getParticipantStatus() {
    if (participant.isPayer) {
      return 'Paid the bill';
    } else if (participant.isSettled) {
      return 'Settled';
    } else {
      return 'Owes';
    }
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1 && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
