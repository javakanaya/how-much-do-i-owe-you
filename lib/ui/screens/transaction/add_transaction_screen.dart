import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_create_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/transaction/participant_selection_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/transaction/widgets/participant_item.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rupiahFormat = AppConstants.rupiahFormat;

  @override
  void initState() {
    super.initState();
    // Initialize with current user as a participant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionCreateProvider.notifier).addCurrentUserAsParticipant();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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

  // Navigate to participant selection screen
  Future<void> _navigateToParticipantSelection() async {
    final transactionNotifier = ref.read(transactionCreateProvider.notifier);

    final selectedUsers = await Navigator.push<List<UserModel>>(
      context,
      MaterialPageRoute(builder: (context) => const ParticipantSelectionScreen()),
    );

    // Add selected users to the transaction
    if (selectedUsers != null && selectedUsers.isNotEmpty) {
      for (final user in selectedUsers) {
        // If you already have the user objects, you can use them directly
        // instead of creating them by email
        transactionNotifier.addParticipantByEmail(user.email, user.displayName);
      }
    }
  }

  // Create transaction
  Future<void> _createTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success =
          await ref.read(transactionCreateProvider.notifier).createTransaction();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.transactionAddedMessage)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionCreateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // MAIN COLUMN (to set the button at the bottom)
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // AMOUNT
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
                            final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            final amount = int.tryParse(numericValue);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            _formatAmountAsRupiah();

                            // Extract numeric value for provider
                            final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            final amount = double.tryParse(numericValue) ?? 0.0;
                            ref
                                .read(transactionCreateProvider.notifier)
                                .setAmount(amount);
                          },
                        ),

                        const SizedBox(height: 16),

                        // DESCRIPTION
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
                            ref
                                .read(transactionCreateProvider.notifier)
                                .setDescription(value);
                          },
                        ),

                        const SizedBox(height: 16),

                        // ADD PARTICIPANTS
                        // Participants section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Who\'s involved?',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            OutlinedButton.icon(
                              onPressed: _navigateToParticipantSelection,
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add Person'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // SPLIT EQUALLY
                        if (transactionState.participants.length > 1)
                          TextButton.icon(
                            onPressed:
                                () =>
                                    ref
                                        .read(transactionCreateProvider.notifier)
                                        .splitEqually(),
                            icon: const Icon(Icons.splitscreen),
                            label: const Text('Split Equally'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                          ),

                        const SizedBox(height: 8),

                        // REMAINING AMOUNT
                        if (_amountController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Remaining amount: ${_rupiahFormat.format(ref.read(transactionCreateProvider.notifier).getRemainingAmount())}',
                              style: TextStyle(
                                color:
                                    ref
                                                .read(transactionCreateProvider.notifier)
                                                .getRemainingAmount()
                                                .abs() <
                                            0.01
                                        ? AppTheme.secondaryColor
                                        : AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // PARTICIPANTS LIST
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactionState.participants.length,
                          itemBuilder: (context, index) {
                            final participant = transactionState.participants[index];
                            return ParticipantItem(
                              participant: participant,
                              onDelete:
                                  () => ref
                                      .read(transactionCreateProvider.notifier)
                                      .removeParticipant(participant.user.id),
                              onAmountChanged:
                                  (amount) => ref
                                      .read(transactionCreateProvider.notifier)
                                      .updateParticipantAmount(
                                        participant.user.id,
                                        amount,
                                      ),
                              isPayerToggled: participant.isPayer,
                              onPayerToggled:
                                  (isToggled) => ref
                                      .read(transactionCreateProvider.notifier)
                                      .toggleParticipantAsPayer(
                                        participant.user.id,
                                        isToggled,
                                      ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                PrimaryButton(
                  text: 'Create Transaction',
                  icon: Icons.check_circle,
                  onPressed: _createTransaction,
                  isLoading: transactionState.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
