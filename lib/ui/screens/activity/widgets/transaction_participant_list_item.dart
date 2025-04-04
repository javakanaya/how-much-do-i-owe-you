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
    final userAsync = ref.watch(dummyUserDataProvider(participant.userId));

    return userAsync.when(
      data: (userData) {
        // Define colors based on participant status
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

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: backgroundColor,
            child:
                userData?.photoURL != null
                    ? CircleAvatar(backgroundImage: NetworkImage(userData!.photoURL!))
                    : Text(
                      _getInitials(userData!.displayName),
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
          ),
          title: Text(
            userData.displayName,
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            _getParticipantStatus(),
            style: TextStyle(color: textColor, fontSize: 12),
          ),
          trailing:
              participant.isPayer
                  ? Icon(Icons.check_circle, color: textColor)
                  : Text(
                    AppConstants.rupiahFormat.format(participant.owedAmount),
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
        );
      },
      loading:
          () => const ListTile(
            leading: CircleAvatar(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            title: Text("Loading..."),
          ),
      error:
          (error, _) => ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.error_outline, color: Colors.white),
            ),
            title: const Text("Failed to load user"),
            subtitle: Text(error.toString(), style: const TextStyle(fontSize: 10)),
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
