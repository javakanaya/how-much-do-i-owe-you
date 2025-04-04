import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _transactionsCollection =>
      _firestore.collection(AppConstants.transactionsCollection);

  Future<TransactionModel> getTransactionById(String id) async {
    final doc = await _transactionsCollection.doc(id).get();

    if (!doc.exists) {
      throw Exception('Transaction not found');
    }

    return TransactionModel.fromFirestore(doc);
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final List<TransactionModel> transactions = [];

    final payerQuerySnapshot =
        await _transactionsCollection.where('payerId', isEqualTo: userId).get();

    for (final doc in payerQuerySnapshot.docs) {
      transactions.add(TransactionModel.fromFirestore(doc));
    }

    final allTransactionQuery =
        await _firestore.collection(AppConstants.transactionsCollection).get();

    for (final doc in allTransactionQuery.docs) {
      if (transactions.any((t) => t.id == doc.id)) {
        continue;
      }

      final transaction = TransactionModel.fromFirestore(doc);
      // Check if user is in participants
      if (transaction.participants.any((p) => p.userId == userId)) {
        transactions.add(transaction);
      }
    }
    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  // Create a new transaction
  Future<String> createTransaction(TransactionModel transaction) async {
    final docRef = await _transactionsCollection.add(transaction.toFirestore());

    return docRef.id;
  }

  // Update a transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsCollection.doc(transaction.id).update(transaction.toFirestore());
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }
}
