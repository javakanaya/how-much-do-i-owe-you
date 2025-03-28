// ui/screens/transaction/widgets/participant_item_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for currency formatting
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_provider.dart';

class ParticipantItemProvider extends StatefulWidget {
  final TransactionParticipant participant;
  final VoidCallback onDelete;

  const ParticipantItemProvider({
    super.key,
    required this.participant,
    required this.onDelete,
  });

  @override
  State<ParticipantItemProvider> createState() =>
      _ParticipantItemProviderState();
}

class _ParticipantItemProviderState extends State<ParticipantItemProvider> {
  late final TextEditingController _amountController;

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _initializeAmountController();
  }

  void _initializeAmountController() {
    _amountController = TextEditingController();
    if (widget.participant.amount != null && widget.participant.amount! > 0) {
      _amountController.text =
          rupiahFormat
              .format(widget.participant.amount!)
              .replaceAll(AppConstants.currencyLocale, '')
              .trim();
    } else {
      _amountController.text = '';
    }
  }

  @override
  void didUpdateWidget(ParticipantItemProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the text controller if the amount changed externally (e.g., "Split Equally")
    if (widget.participant.amount != oldWidget.participant.amount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.participant.amount != null &&
              widget.participant.amount! > 0) {
            _amountController.text =
                rupiahFormat
                    .format(widget.participant.amount!)
                    .replaceAll(AppConstants.currencyLocale, '')
                    .trim();
          } else {
            _amountController.text = '';
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Format amount as Rupiah
  void _formatAmountAsRupiah() {
    if (_amountController.text.isEmpty) return;

    // Remove non-numeric characters and parse
    String numericText = _amountController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (numericText.isEmpty) {
      _amountController.text = '';
      return;
    }

    double amount = double.parse(numericText);

    // Format as Rupiah (without symbol)
    String formatted =
        rupiahFormat
            .format(amount)
            .replaceAll(AppConstants.currencyLocale, '')
            .trim();

    // Update text field without triggering another formatting cycle
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.participant.user;
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.end,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _formatAmountAsRupiah();

                  // Use addPostFrameCallback to avoid setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // Extract numeric value
                    final numericValue = value.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );
                    final amount = double.tryParse(numericValue);
                    transactionProvider.updateParticipantAmount(
                      user.id,
                      amount,
                    );
                  });
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
