// services/transaction_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/participant_model.dart';
import 'package:how_much_do_i_owe_you/services/balance_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BalanceService _balanceService = BalanceService();
  final Uuid _uuid = const Uuid();

  // Create a new transaction
  Future<String> createTransaction({
    required String description,
    required double amount,
    required String payerId,
    required List<ParticipantModel> participants,
  }) async {
    try {
      // Validate current user is the payer
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (currentUser.uid != payerId) {
        throw Exception('Only the payer can create a transaction');
      }

      // Create transaction ID
      final String transactionId = _uuid.v4();

      // Extract participant IDs
      final List<String> participantIds =
          participants.map((p) => p.userId).toList();

      // Create transaction document
      final TransactionModel transaction = TransactionModel(
        transactionId: transactionId,
        description: description,
        amount: amount,
        date: DateTime.now(),
        payerId: payerId,
        status: 'active', // Active status for new transactions
        participants: participantIds,
      );

      // Create batch operation
      final WriteBatch batch = _firestore.batch();

      // Add transaction to Firestore
      final transactionRef = _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId);

      batch.set(transactionRef, transaction.toMap());

      // Add participant records
      for (var participant in participants) {
        final participantRef = _firestore
            .collection(AppConstants.participantsCollection)
            .doc('${transactionId}_${participant.userId}');

        // Create a proper participant model using the incoming model
        final participantModel = ParticipantModel(
          userId: participant.userId,
          transactionId: transactionId,
          owedAmount: participant.owedAmount,
          isPayer: participant.isPayer,
          isSettled: participant.isPayer, // Payer is considered settled
        );
        batch.set(participantRef, participantModel.toMap());

        // Update balance if not the payer
        if (!participant.isPayer) {
          // Update balance between payer and participant
          await _balanceService.updateBalanceAfterTransaction(
            payerId,
            participant.userId,
            participant.owedAmount,
          );
        }
      }

      // Award points to the current user for creating a transaction
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid);

      batch.update(userRef, {
        'totalPoints': FieldValue.increment(
          AppConstants.pointsForNewTransaction,
        ),
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return transactionId;
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Get a specific transaction by ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final doc =
          await _firestore
              .collection(AppConstants.transactionsCollection)
              .doc(transactionId)
              .get();

      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      return null;
    }
  }

  // Get transactions for a specific user
  Future<List<TransactionModel>> getTransactionsForUser(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(AppConstants.transactionsCollection)
              .where('participants', arrayContains: userId)
              .orderBy('date', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  // Get participants for a specific transaction
  Future<List<ParticipantModel>> getParticipantsForTransaction(
    String transactionId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(AppConstants.participantsCollection)
              .where('transactionId', isEqualTo: transactionId)
              .get();

      return querySnapshot.docs
          .map((doc) => ParticipantModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting participants: $e');
      return [];
    }
  }

  // Mark a participant as settled in a transaction
  Future<void> markParticipantSettled(
    String transactionId,
    String userId,
  ) async {
    try {
      final docId = '${transactionId}_$userId';

      // Update participant record
      await _firestore
          .collection(AppConstants.participantsCollection)
          .doc(docId)
          .update({
            'isSettled': true,
            'settledAt': FieldValue.serverTimestamp(),
          });

      // Check if all participants are settled
      final participants = await getParticipantsForTransaction(transactionId);
      final allSettled = participants.every((p) => p.isSettled);

      // If all settled, update transaction status
      if (allSettled) {
        await _firestore
            .collection(AppConstants.transactionsCollection)
            .doc(transactionId)
            .update({'status': 'settled'});
      }
    } catch (e) {
      debugPrint('Error marking participant settled: $e');
      throw Exception('Failed to mark as settled: $e');
    }
  }

  // Delete a transaction (only if it's the payer and no one has settled yet)
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get transaction
      final transaction = await getTransactionById(transactionId);
      if (transaction == null) {
        throw Exception('Transaction not found');
      }

      // Validate user is the payer
      if (transaction.payerId != currentUser.uid) {
        throw Exception('Only the payer can delete a transaction');
      }

      // Get participants
      final participants = await getParticipantsForTransaction(transactionId);

      // Check if any non-payer participant has settled
      final anySettled = participants
          .where((p) => !p.isPayer)
          .any((p) => p.isSettled);

      if (anySettled) {
        throw Exception(
          'Cannot delete a transaction that has been partially settled',
        );
      }

      // Create batch operation
      final WriteBatch batch = _firestore.batch();

      // Delete transaction
      batch.delete(
        _firestore
            .collection(AppConstants.transactionsCollection)
            .doc(transactionId),
      );

      // Delete all participants
      for (var participant in participants) {
        batch.delete(
          _firestore
              .collection(AppConstants.participantsCollection)
              .doc('${transactionId}_${participant.userId}'),
        );
      }

      // Reverse balance changes
      for (var participant in participants) {
        if (!participant.isPayer) {
          // Inverse the amount to update balance
          await _balanceService.updateBalanceAfterTransaction(
            transaction.payerId,
            participant.userId,
            -participant.owedAmount, // Negative to reverse
          );
        }
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction: $e');
    }
  }
}

// Note: Using ParticipantModel from models instead of a separate TransactionParticipant class
