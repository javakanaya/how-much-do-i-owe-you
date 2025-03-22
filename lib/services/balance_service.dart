// services/balance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';
import '../models/balance_model.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class BalanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all balances involving a specific user
  Future<List<BalanceModel>> fetchUserBalances(String userId) async {
    try {
      // Get balances where user is userIdA
      final querySnapshotA =
          await _firestore
              .collection(AppConstants.balancesCollection)
              .where('userIdA', isEqualTo: userId)
              .get();

      // Get balances where user is userIdB
      final querySnapshotB =
          await _firestore
              .collection(AppConstants.balancesCollection)
              .where('userIdB', isEqualTo: userId)
              .get();

      // Combine and convert to BalanceModel objects
      final balanceModels = [
        ...querySnapshotA.docs.map((doc) => BalanceModel.fromFirestore(doc)),
        ...querySnapshotB.docs.map((doc) => BalanceModel.fromFirestore(doc)),
      ];

      return balanceModels;
    } catch (e) {
      debugPrint('Error fetching balances: $e');
      throw Exception('Failed to fetch balances: $e');
    }
  }

  // Fetch a user model by ID
  Future<UserModel?> fetchUserById(String userId) async {
    try {
      final userDoc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  // Count transactions between two users
  Future<int> countTransactionsBetweenUsers(
    String userId,
    String otherUserId,
  ) async {
    try {
      // Get all transactions where current user is a participant
      final querySnapshot =
          await _firestore
              .collection(AppConstants.transactionsCollection)
              .where('participants', arrayContains: userId)
              .get();

      // Filter to only include transactions with the other user
      final relevantTransactions =
          querySnapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .where(
                (transaction) => transaction.participants.contains(otherUserId),
              )
              .toList();

      return relevantTransactions.length;
    } catch (e) {
      debugPrint('Error counting transactions: $e');
      return 0;
    }
  }

  // Update a balance between two users
  Future<void> updateBalance(BalanceModel balance) async {
    try {
      await _firestore
          .collection(AppConstants.balancesCollection)
          .doc(balance.balanceId)
          .set(balance.toMap());
    } catch (e) {
      debugPrint('Error updating balance: $e');
      throw Exception('Failed to update balance: $e');
    }
  }

  // Create a new balance between two users
  Future<String> createBalance(BalanceModel balance) async {
    try {
      final docRef =
          _firestore.collection(AppConstants.balancesCollection).doc();
      final newBalance = balance.copyWith(balanceId: docRef.id);

      await docRef.set(newBalance.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating balance: $e');
      throw Exception('Failed to create balance: $e');
    }
  }

  // Get a specific balance between two users
  Future<BalanceModel?> getBalanceBetweenUsers(
    String userIdA,
    String userIdB,
  ) async {
    try {
      // Check in both directions (userIdA-userIdB and userIdB-userIdA)
      final querySnapshot1 =
          await _firestore
              .collection(AppConstants.balancesCollection)
              .where('userIdA', isEqualTo: userIdA)
              .where('userIdB', isEqualTo: userIdB)
              .limit(1)
              .get();

      if (querySnapshot1.docs.isNotEmpty) {
        return BalanceModel.fromFirestore(querySnapshot1.docs.first);
      }

      final querySnapshot2 =
          await _firestore
              .collection(AppConstants.balancesCollection)
              .where('userIdA', isEqualTo: userIdB)
              .where('userIdB', isEqualTo: userIdA)
              .limit(1)
              .get();

      if (querySnapshot2.docs.isNotEmpty) {
        return BalanceModel.fromFirestore(querySnapshot2.docs.first);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting balance between users: $e');
      return null;
    }
  }

  // Update balance after a transaction
  Future<void> updateBalanceAfterTransaction(
    String payerId,
    String borrowerId,
    double amount,
  ) async {
    try {
      // Get existing balance between users
      BalanceModel? existingBalance = await getBalanceBetweenUsers(
        payerId,
        borrowerId,
      );

      if (existingBalance != null) {
        // Update existing balance
        double newAmount = existingBalance.amount;

        // If payer is userIdA, add amount; otherwise subtract
        if (existingBalance.userIdA == payerId) {
          newAmount += amount;
        } else {
          newAmount -= amount;
        }

        // Update balance
        final updatedBalance = existingBalance.copyWith(
          amount: newAmount,
          lastUpdated: DateTime.now(),
        );

        await updateBalance(updatedBalance);
      } else {
        // Create new balance
        final newBalance = BalanceModel(
          balanceId: '', // Will be set by createBalance
          userIdA: payerId,
          userIdB: borrowerId,
          amount: amount,
          lastUpdated: DateTime.now(),
        );

        await createBalance(newBalance);
      }
    } catch (e) {
      debugPrint('Error updating balance after transaction: $e');
      throw Exception('Failed to update balance: $e');
    }
  }

  // Update balance after a settlement
  Future<void> updateBalanceAfterSettlement(
    String payerId,
    String receiverId,
    double amount,
  ) async {
    try {
      // Get existing balance between users
      BalanceModel? existingBalance = await getBalanceBetweenUsers(
        payerId,
        receiverId,
      );

      if (existingBalance != null) {
        // Update existing balance
        double newAmount = existingBalance.amount;

        // If payer is userIdA, add amount; otherwise subtract
        if (existingBalance.userIdA == payerId) {
          newAmount += amount;
        } else {
          newAmount -= amount;
        }

        // Update balance
        final updatedBalance = existingBalance.copyWith(
          amount: newAmount,
          lastUpdated: DateTime.now(),
        );

        await updateBalance(updatedBalance);
      } else {
        // This shouldn't happen for a settlement (as there should already be a balance)
        // but we'll handle it just in case
        final newBalance = BalanceModel(
          balanceId: '', // Will be set by createBalance
          userIdA: payerId,
          userIdB: receiverId,
          amount: amount,
          lastUpdated: DateTime.now(),
        );

        await createBalance(newBalance);
      }
    } catch (e) {
      debugPrint('Error updating balance after settlement: $e');
      throw Exception('Failed to update balance: $e');
    }
  }
}
