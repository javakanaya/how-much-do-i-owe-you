// ui/screens/transaction/transaction_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/providers/participant_item_provider.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_provider.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';
import 'package:how_much_do_i_owe_you/ui/screens/transaction/user_search_screen.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class TransactionCreationScreen extends StatefulWidget {
  const TransactionCreationScreen({super.key});

  @override
  State<TransactionCreationScreen> createState() =>
      _TransactionCreationScreenState();
}

class _TransactionCreationScreenState extends State<TransactionCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    // Add current user as a participant and payer by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).initializeWithUser(authProvider.userModel!);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Open screen to search and add multiple users
  Future<void> _addParticipant(TransactionProvider provider) async {
    // Get list of current participants for the UserSearchScreen
    final currentParticipants = provider.participants;
    final alreadySelectedUserIds =
        currentParticipants
            .map((participant) => participant.user.userId)
            .toList();

    final result = await Navigator.push<List<UserModel>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => UserSearchScreen(
              alreadySelectedUserIds: alreadySelectedUserIds,
            ),
      ),
    );

    if (result != null) {
      // Update participants in the provider
      provider.updateParticipants(result);

      // If we have an amount, suggest splitting equally
      if (_amountController.text.isNotEmpty) {
        provider.splitEqually();
      }
    }
  }

  // Create transaction
  Future<void> _createTransaction(TransactionProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    // Parse amount from text field, removing Rupiah format
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountText) ?? 0.0;

    provider.setAmount(amount);
    provider.setDescription(_descriptionController.text);

    // Create the transaction
    final success = await provider.createTransaction();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction created successfully!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );

      // Return to previous screen
      Navigator.pop(context, true);

      // Reset the provider for the next transaction
      provider.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to create transaction',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
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

    // Format as Rupiah
    String formatted = rupiahFormat.format(amount);

    // Update text field without triggering another formatting cycle
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Amount field
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: 'Enter total amount',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            // Clean the input and check if it's a valid number
                            final numericValue = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            final amount = int.tryParse(numericValue);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            _formatAmountAsRupiah();

                            // Extract numeric value for provider
                            final numericValue = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            final amount = double.tryParse(numericValue) ?? 0.0;
                            transactionProvider.setAmount(amount);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Description field
                        CustomInputField(
                          controller: _descriptionController,
                          labelText: 'Description',
                          hintText: 'What was this expense for?',
                          prefixIcon: Icons.description_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            transactionProvider.setDescription(value);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Participants section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Who\'s involved?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed:
                                  () => _addParticipant(transactionProvider),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add Person'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Split equally button
                        if (transactionProvider.participants.length > 1)
                          TextButton.icon(
                            onPressed: () => transactionProvider.splitEqually(),
                            icon: const Icon(Icons.splitscreen),
                            label: const Text('Split Equally'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Remaining amount indicator
                        if (_amountController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Remaining amount: ${rupiahFormat.format(transactionProvider.getRemainingAmount())}',
                              style: TextStyle(
                                color:
                                    transactionProvider
                                                .getRemainingAmount()
                                                .abs() <
                                            0.01
                                        ? AppTheme.secondaryColor
                                        : AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Participants list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactionProvider.participants.length,
                          itemBuilder: (context, index) {
                            final participant =
                                transactionProvider.participants[index];
                            return ParticipantItemProvider(
                              participant: participant,
                              onDelete:
                                  () => transactionProvider.removeParticipant(
                                    participant.user.userId,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Create Transaction Button
                PrimaryButton(
                  text: 'Create Transaction',
                  icon: Icons.check_circle,
                  onPressed:
                      transactionProvider.isLoading
                          ? () {}
                          : () => _createTransaction(transactionProvider),
                  isLoading: transactionProvider.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
