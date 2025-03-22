// ui/screens/transaction/widgets/participant_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';

class ParticipantEntry {
  final UserModel user;
  final double? amount;
  final bool isPayer;

  ParticipantEntry({required this.user, this.amount, required this.isPayer});

  ParticipantEntry copyWith({UserModel? user, double? amount, bool? isPayer}) {
    return ParticipantEntry(
      user: user ?? this.user,
      amount: amount ?? this.amount,
      isPayer: isPayer ?? this.isPayer,
    );
  }
}

class ParticipantItem extends StatefulWidget {
  final ParticipantEntry participant;
  final Function(double?) onAmountChanged;
  final VoidCallback onDelete;

  const ParticipantItem({
    super.key,
    required this.participant,
    required this.onAmountChanged,
    required this.onDelete,
  });

  @override
  State<ParticipantItem> createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text:
          widget.participant.amount != null && widget.participant.amount! > 0
              ? widget.participant.amount!.toStringAsFixed(2)
              : '',
    );
  }

  @override
  void didUpdateWidget(ParticipantItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the text controller if the amount changed externally (e.g., "Split Equally")
    if (widget.participant.amount != oldWidget.participant.amount) {
      _amountController.text =
          widget.participant.amount != null && widget.participant.amount! > 0
              ? widget.participant.amount!.toStringAsFixed(2)
              : '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.participant.user;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // User avatar
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              radius: 24,
              child:
                  user.photoURL != null
                      ? CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(user.photoURL!),
                      )
                      : Text(
                        _getInitials(user.displayName),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),

            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (widget.participant.isPayer)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Paid',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Amount field
            SizedBox(
              width: 100,
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  prefixText: '\$',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.end,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  widget.onAmountChanged(amount);
                },
              ),
            ),

            // Delete button
            if (!widget.participant.isPayer)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                ),
                onPressed: widget.onDelete,
              ),
          ],
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
}
