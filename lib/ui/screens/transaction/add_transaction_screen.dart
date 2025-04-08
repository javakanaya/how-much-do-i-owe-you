import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: SafeArea(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // MAIN COLUMN (to set the button at the bottom)
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // AMOUNT
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 16),

                        // DESCRIPTION
                        CustomInputField(
                          controller: TextEditingController(),
                          labelText: 'Description',
                          hintText: 'What was this expense for?',
                          prefixIcon: Icons.description_outlined,
                        ),

                        const SizedBox(height: 16),

                        // ADD PARTICIPANTS
                        Row(
                          children: [
                            const Text('Who\'s involved?'),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add Person'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // SPLIT EQUALLY
                        TextButton.icon(
                          onPressed: () {},
                          label: const Text('Split Equally'),
                          icon: const Icon(Icons.splitscreen),
                        ),

                        const SizedBox(height: 8),

                        // REMAINING AMOUNT
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text('Remaining amount xxx '),
                        ),

                        // PARTICIPANTS LIST
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3, // Replace with actual participant count
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Participant ${index + 1}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {},
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
