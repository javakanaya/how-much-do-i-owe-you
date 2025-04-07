import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/transaction_detail_card.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/transaction_detail_header.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/transaction_participants_list.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get transaction data
    final transactionAsync = ref.watch(transactionDataProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: transactionAsync.when(
        data:
            (transactionData) => SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TransactionDetailHeader(transaction: transactionData),
                  TransactionDetailCard(transaction: transactionData),
                  TransactionParticipantsList(participants: transactionData.participants),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Error loading transactiondata: $error')),
      ),
    );
  }
}
