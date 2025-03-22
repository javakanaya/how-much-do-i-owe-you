// services/settlement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';
import 'package:how_much_do_i_owe_you/services/balance_service.dart';

class SettlementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();
  final BalanceService _balanceService = BalanceService();

  // Create a new settlement
  Future<String> createSettlement(SettlementModel settlement) async {
    try {
      // Create batch operation
      final WriteBatch batch = _firestore.batch();

      // Add settlement to Firestore
      final settlementRef = _firestore
          .collection(AppConstants.settlementsCollection)
          .doc(settlement.settlementId);

      batch.set(settlementRef, settlement.toMap());

      // Mark all transactions as settled for the current user
      for (var transactionId in settlement.transactionIds) {
        await _transactionService.markParticipantSettled(
          transactionId,
          settlement.payerId,
        );
      }

      // Update balance between users
      await _balanceService.updateBalanceAfterSettlement(
        settlement.payerId,
        settlement.receiverId,
        settlement.amount,
      );

      // Award points to both users for settlement
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(settlement.payerId);

      batch.update(userRef, {
        'totalPoints': FieldValue.increment(AppConstants.pointsForSettlement),
        'lastActive': FieldValue.serverTimestamp(),
      });

      final receiverRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(settlement.receiverId);

      batch.update(receiverRef, {
        'totalPoints': FieldValue.increment(AppConstants.pointsForSettlement),
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return settlement.settlementId;
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

  // Get settlements for a specific user
  Future<List<SettlementModel>> getSettlementsForUser(String userId) async {
    try {
      // Get settlements where user is payer or receiver
      final querySnapshot1 =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .where('payerId', isEqualTo: userId)
              .get();

      final querySnapshot2 =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .where('receiverId', isEqualTo: userId)
              .get();

      // Combine the results
      final settlements = [
        ...querySnapshot1.docs.map((doc) => SettlementModel.fromFirestore(doc)),
        ...querySnapshot2.docs.map((doc) => SettlementModel.fromFirestore(doc)),
      ];

      // Sort by date (newest first)
      settlements.sort((a, b) => b.date.compareTo(a.date));

      return settlements;
    } catch (e) {
      debugPrint('Error getting settlements: $e');
      return [];
    }
  }

  // Cancel a settlement (within 24 hours only)
  Future<bool> cancelSettlement(String settlementId) async {
    try {
      // Get the settlement
      final doc =
          await _firestore
              .collection(AppConstants.settlementsCollection)
              .doc(settlementId)
              .get();

      if (!doc.exists) {
        throw Exception('Settlement not found');
      }

      final settlement = SettlementModel.fromFirestore(doc);

      // Check if settlement is within 24 hours
      final now = DateTime.now();
      final difference = now.difference(settlement.date);
      if (difference.inHours > 24) {
        throw Exception('Settlements can only be canceled within 24 hours');
      }

      // Create batch operation
      final WriteBatch batch = _firestore.batch();

      // Update settlement status
      batch.update(doc.reference, {'status': 'canceled'});

      // Unmark all transactions
      for (var transactionId in settlement.transactionIds) {
        await _transactionService.unmarkParticipantSettled(
          transactionId,
          settlement.payerId,
        );
      }

      // Reverse balance change
      await _balanceService.updateBalanceAfterSettlement(
        settlement.payerId,
        settlement.receiverId,
        -settlement.amount, // Negative to reverse the settlement
      );

      // Deduct points from both users
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(settlement.payerId);

      batch.update(userRef, {
        'totalPoints': FieldValue.increment(-AppConstants.pointsForSettlement),
        'lastActive': FieldValue.serverTimestamp(),
      });

      final receiverRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(settlement.receiverId);

      batch.update(receiverRef, {
        'totalPoints': FieldValue.increment(-AppConstants.pointsForSettlement),
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      return true;
    } catch (e) {
      debugPrint('Error canceling settlement: $e');
      return false;
    }
  }
}
