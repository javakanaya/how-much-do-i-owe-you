import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/transaction_participant_list_item.dart';

class TransactionParticipantsList extends StatelessWidget {
  final List<TransactionParticipant> participants;

  const TransactionParticipantsList({super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Participants', style: AppTheme.h2Style),
        const SizedBox(height: 4),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children:
                  participants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final participant = entry.value;

                    return Column(
                      children: [
                        TransactionParticipantListItem(participant: participant),
                        // Add divider for all except the last item
                        if (index < participants.length - 1)
                          const Divider(
                            height: 32,
                            thickness: 1,
                            color: AppTheme.dividerColor,
                          ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
