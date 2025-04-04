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
        const Text(
          'Participants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder:
                  (context, index) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: AppTheme.dividerColor,
                  ),
              itemBuilder:
                  (context, index) =>
                      TransactionParticipantListItem(participant: participants[index]),
            ),
          ),
        ),
      ],
    );
  }
}
