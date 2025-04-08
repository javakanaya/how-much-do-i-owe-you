import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_create_provider.dart';

class ParticipantItem extends StatefulWidget {
  final TransactionParticipantEntry participant;
  final VoidCallback onDelete;
  final Function(double) onAmountChanged;
  final bool isPayerToggled;
  final Function(bool) onPayerToggled;

  const ParticipantItem({
    super.key,
    required this.participant,
    required this.onDelete,
    required this.onAmountChanged,
    required this.isPayerToggled,
    required this.onPayerToggled,
  });

  @override
  State<ParticipantItem> createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem> {
  late TextEditingController _amountController;
  final _rupiahFormat = AppConstants.rupiahFormat;

  @override
  void initState() {
    super.initState();
    // Initialize with existing amount if any
    _amountController = TextEditingController(
      text:
          widget.participant.amount > 0
              ? _rupiahFormat.format(widget.participant.amount)
              : '',
    );
  }

  @override
  void didUpdateWidget(ParticipantItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if participant amount changes (like when splitting equally)
    if (oldWidget.participant.amount != widget.participant.amount) {
      final newText =
          widget.participant.amount > 0
              ? _rupiahFormat.format(widget.participant.amount)
              : '';

      _amountController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Format amount as Rupiah
  void _formatAmountAsRupiah() {
    final text = _amountController.text;
    if (text.isEmpty) return;

    // Remove all non-numeric characters
    final numericValue = text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(numericValue) ?? 0;

    // Format using the Rupiah formatter
    final formattedText = _rupiahFormat.format(amount);

    // Update text field without triggering onChanged
    _amountController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: widget.isPayerToggled ? AppTheme.primaryColor : Colors.grey.shade300,
          width: widget.isPayerToggled ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryLightColor,
                  radius: 18,
                  child: Text(
                    widget.participant.user.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.participant.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        widget.participant.user.email,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Payer toggle switch
                SizedBox(
                  height: 30,
                  child: Switch(
                    value: widget.isPayerToggled,
                    onChanged: widget.onPayerToggled,
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                const Text('Paid for this', style: TextStyle(fontSize: 14)),
                const Spacer(),
                // Amount field
                SizedBox(
                  width: 150,
                  height: 40,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      _formatAmountAsRupiah();

                      // Extract numeric value and pass to parent
                      final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = double.tryParse(numericValue) ?? 0.0;
                      widget.onAmountChanged(amount);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
