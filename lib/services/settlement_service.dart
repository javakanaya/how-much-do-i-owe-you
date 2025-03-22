// services/settlement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/services/balance_service.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';

class SettlementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BalanceService _balanceService = BalanceService();
  final TransactionService _transactionService = TransactionService();
  final Uuid _uuid = const Uuid();

  // Create a new settlement between two users
  Future<String> createSettlement({
    required String payerId,
    required String receiverId,
    required double amount,
    required List<String> transactionIds,
  }) async {
    try {
      // Validate current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Only the payer can create the settlement
      if (currentUser.uid != payerId) {
        throw Exception('Only the payer can create a settlement');
      }

      // Create settlement ID
      final String settlementId = _uuid.v4();

      // Create settlement document
      final SettlementModel settlement = SettlementModel(
        settlementId: settlementId,
        payerId: payerId,
        receiverId: receiverId,
        amount: amount,
        date: DateTime.now(),
        status: 'completed',
        transactionIds: transactionIds,
      );

      // Create batch operation
      final WriteBatch batch = _firestore.batch();

      // Add settlement to Firestore
      final settlementRef = _firestore
          .collection(AppConstants.settlementsCollection)
          .doc(settlementId);

      batch.set(settlementRef, settlement.toMap());

      // Update transaction statuses
      for (var transactionId in transactionIds) {
        // Mark participants as settled in the transaction
        final participants = await _transactionService
            .getParticipantsForTransaction(transactionId);

        for (var participant in participants) {
          // If the participant is the payer of this settlement, mark them as settled
          if (participant.userId == payerId) {
            final participantRef = _firestore
                .collection(AppConstants.participantsCollection)
                .doc('${transactionId}_${participant.userId}');

            batch.update(participantRef, {
              'isSettled': true,
              'settledAt': FieldValue.serverTimestamp(),
            });
          }
        }

        // Check if all participants are now settled
        bool allSettled = true;
        for (var participant in participants) {
          if (participant.userId == payerId) {
            // This participant is now settled
            continue;
          } else if (!participant.isSettled) {
            allSettled = false;
            break;
          }
        }

        // If all participants are settled, update transaction status
        if (allSettled) {
          final transactionRef = _firestore
              .collection(AppConstants.transactionsCollection)
              .doc(transactionId);

          batch.update(transactionRef, {'status': 'settled'});
        }
      }

      // Update balance between users
      await _balanceService.updateBalanceAfterSettlement(
        payerId,
        receiverId,
        -amount, // Negative because this reduces what the payer owes
      );

      // Award points to the current user for settlement
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid);

      batch.update(userRef, {
        'totalPoints': FieldValue.increment(AppConstants.pointsForSettlement),
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return settlementId;
    } catch (e) {
      debugPrint('Error creating settlement: $e');
      throw Exception('Failed to create settlement: $e');
    }
  }

  // Get a specific settlement by ID
  Future<SettlementModel?> getSettlementById(String settlementId) async {
    try {
      final doc =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .doc(settlementId)
              .get();

      if (doc.exists) {
        return SettlementModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting settlement: $e');
      return null;
    }
  }

  // Get settlements for a specific user (as payer or receiver)
  Future<List<SettlementModel>> getSettlementsForUser(String userId) async {
    try {
      // Get settlements where user is payer
      final payerSnapshot =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .where('payerId', isEqualTo: userId)
              .get();

      // Get settlements where user is receiver
      final receiverSnapshot =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .where('receiverId', isEqualTo: userId)
              .get();

      // Combine results
      final List<SettlementModel> settlements = [
        ...payerSnapshot.docs.map((doc) => SettlementModel.fromFirestore(doc)),
        ...receiverSnapshot.docs.map(
          (doc) => SettlementModel.fromFirestore(doc),
        ),
      ];

      // Sort in memory instead of in the query
      settlements.sort((a, b) => b.date.compareTo(a.date));

      return settlements;
    } catch (e) {
      debugPrint('Error getting settlements: $e');
      return [];
    }
  }

  // Get settlements between two specific users
  Future<List<SettlementModel>> getSettlementsBetweenUsers(
    String userIdA,
    String userIdB,
  ) async {
    try {
      // Get where A is payer and B is receiver
      final query1 =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .where('payerId', isEqualTo: userIdA)
              .where('receiverId', isEqualTo: userIdB)
              .get();

      // Get where B is payer and A is receiver
      final query2 =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .where('payerId', isEqualTo: userIdB)
              .where('receiverId', isEqualTo: userIdA)
              .get();

      // Combine results
      final List<SettlementModel> settlements = [
        ...query1.docs.map((doc) => SettlementModel.fromFirestore(doc)),
        ...query2.docs.map((doc) => SettlementModel.fromFirestore(doc)),
      ];

      // Sort by date (newest first)
      settlements.sort((a, b) => b.date.compareTo(a.date));

      return settlements;
    } catch (e) {
      debugPrint('Error getting settlements between users: $e');
      return [];
    }
  }

  // Cancel a settlement (only if it was created recently, e.g., within 24 hours)
  Future<bool> cancelSettlement(String settlementId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get settlement
      final settlement = await getSettlementById(settlementId);
      if (settlement == null) {
        throw Exception('Settlement not found');
      }

      // Check if user is the payer or receiver
      if (settlement.payerId != currentUser.uid &&
          settlement.receiverId != currentUser.uid) {
        throw Exception('You do not have permission to cancel this settlement');
      }

      // Check if settlement is recent enough to cancel
      final now = DateTime.now();
      final difference = now.difference(settlement.date);
      if (difference.inHours > 24) {
        throw Exception('Settlements can only be cancelled within 24 hours');
      }

      // Create batch operation
      final WriteBatch batch = _firestore.batch();

      // Update settlement status
      final settlementRef = _firestore
          .collection(AppConstants.settlementsCollection)
          .doc(settlementId);

      batch.update(settlementRef, {'status': 'canceled'});

      // Revert transaction statuses if needed
      for (var transactionId in settlement.transactionIds) {
        // Get the transaction to check its status
        final transaction = await _transactionService.getTransactionById(
          transactionId,
        );
        if (transaction == null) continue;

        // If transaction was settled, revert to active
        if (transaction.status == 'settled') {
          final transactionRef = _firestore
              .collection(AppConstants.transactionsCollection)
              .doc(transactionId);

          batch.update(transactionRef, {'status': 'active'});
        }

        // Revert participant settlement status
        final participantRef = _firestore
            .collection(AppConstants.participantsCollection)
            .doc('${transactionId}_${settlement.payerId}');

        batch.update(participantRef, {'isSettled': false, 'settledAt': null});
      }

      // Revert balance changes
      await _balanceService.updateBalanceAfterSettlement(
        settlement.payerId,
        settlement.receiverId,
        settlement.amount, // Positive to undo the negative adjustment
      );

      // Deduct points
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid);

      batch.update(userRef, {
        'totalPoints': FieldValue.increment(-AppConstants.pointsForSettlement),
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return true;
    } catch (e) {
      debugPrint('Error cancelling settlement: $e');
      return false;
    }
  }

  // Get transactions that can be settled between two users
  Future<List<TransactionModel>> getSettleableTransactions(
    String payerId,
    String receiverId,
  ) async {
    try {
      // Get all transactions where the receiver is the payer and the payer is a participant
      final querySnapshot =
          await _firestore
              .collection(AppConstants.transactionsCollection)
              .where('payerId', isEqualTo: receiverId)
              .where('participants', arrayContains: payerId)
              .where('status', isEqualTo: 'active')
              .get();

      final transactions =
          querySnapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();

      // Filter to only include transactions where the payer hasn't settled yet
      final List<TransactionModel> settleableTransactions = [];

      for (var transaction in transactions) {
        // Get the participant record for the payer
        final participantSnapshot =
            await _firestore
                .collection(AppConstants.participantsCollection)
                .doc('${transaction.transactionId}_$payerId')
                .get();

        if (participantSnapshot.exists) {
          final data = participantSnapshot.data() as Map<String, dynamic>;
          final isSettled = data['isSettled'] ?? false;

          if (!isSettled) {
            settleableTransactions.add(transaction);
          }
        }
      }

      return settleableTransactions;
    } catch (e) {
      debugPrint('Error getting settleable transactions: $e');
      return [];
    }
  }

  // Calculate total outstanding amount between two users
  Future<double> calculateOutstandingAmount(
    String payerId,
    String receiverId,
  ) async {
    try {
      final transactions = await getSettleableTransactions(payerId, receiverId);

      double totalAmount = 0.0;

      for (var transaction in transactions) {
        // Get the participant record to find exact owed amount
        final participantSnapshot =
            await _firestore
                .collection(AppConstants.participantsCollection)
                .doc('${transaction.transactionId}_$payerId')
                .get();

        if (participantSnapshot.exists) {
          final data = participantSnapshot.data() as Map<String, dynamic>;
          final owedAmount =
              (data['owedAmount'] is int)
                  ? (data['owedAmount'] as int).toDouble()
                  : data['owedAmount'] ?? 0.0;

          totalAmount += owedAmount;
        }
      }

      return totalAmount;
    } catch (e) {
      debugPrint('Error calculating outstanding amount: $e');
      return 0.0;
    }
  }
}
