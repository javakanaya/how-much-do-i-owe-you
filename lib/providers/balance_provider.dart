// providers/balance_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:how_much_do_i_owe_you/models/balance_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/models/person_balance_model.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';

class BalanceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user ID
  String? _currentUserId;

  // List of all balances involving the current user
  List<PersonBalance> _personBalances = [];

  // Total balance (positive = owed to user, negative = user owes)
  double _totalBalance = 0.0;

  // Getter for the total balance
  double get totalBalance => _totalBalance;

  // Getter for all person balances
  List<PersonBalance> get personBalances => _personBalances;

  // Initialize with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    fetchBalances();
  }

  // Fetch balances from Firestore
  Future<void> fetchBalances() async {
    if (_currentUserId == null) return;

    try {
      // Get all balances where current user is either userIdA or userIdB
      final querySnapshotA =
          await _firestore
              .collection('BALANCES')
              .where('userIdA', isEqualTo: _currentUserId)
              .get();

      final querySnapshotB =
          await _firestore
              .collection('BALANCES')
              .where('userIdB', isEqualTo: _currentUserId)
              .get();

      // Combine results
      final balanceModels = [
        ...querySnapshotA.docs.map((doc) => BalanceModel.fromFirestore(doc)),
        ...querySnapshotB.docs.map((doc) => BalanceModel.fromFirestore(doc)),
      ];

      // Reset total balance
      _totalBalance = 0.0;

      // Create PersonBalance list
      final List<PersonBalance> newPersonBalances = [];

      // Process each balance
      for (var balance in balanceModels) {
        // Get the other user's ID
        final otherUserId = balance.getOtherUserId(_currentUserId!);

        // Get user data
        final userDoc =
            await _firestore.collection('USERS').doc(otherUserId).get();

        if (!userDoc.exists) continue;

        final userModel = UserModel.fromFirestore(userDoc);

        // Count transactions
        final transactionCount = await _countTransactions(otherUserId);

        // Create PersonBalance object
        final personBalance = PersonBalance.fromModels(
          balanceModel: balance,
          userModel: userModel,
          currentUserId: _currentUserId!,
          transactionCount: transactionCount,
        );

        // Add to list
        newPersonBalances.add(personBalance);

        // Update total balance
        // If positive (they owe us), add to total
        // If negative (we owe them), subtract from total
        if (personBalance.isPositive) {
          _totalBalance += personBalance.balance;
        } else {
          _totalBalance -= personBalance.balance;
        }
      }

      // Update the list
      _personBalances = newPersonBalances;
      notifyListeners();
    } catch (e) {
      print('Error fetching balances: $e');
      // In case of error, use dummy data for development
      _personBalances = PersonBalance.getDummyData();
      _totalBalance = 27.50; // 42.50 - 15.00
      notifyListeners();
    }
  }

  // Helper to count transactions between current user and another user
  Future<int> _countTransactions(String otherUserId) async {
    if (_currentUserId == null) return 0;

    try {
      // Get all transactions where both users are participants
      final querySnapshot =
          await _firestore
              .collection('TRANSACTIONS')
              .where('participants', arrayContains: _currentUserId)
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
      print('Error counting transactions: $e');
      return 0;
    }
  }

  // Get PersonBalance for a specific user
  PersonBalance? getPersonBalance(String userId) {
    try {
      return _personBalances.firstWhere((balance) => balance.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Get formatted total balance string
  String getFormattedTotalBalance() {
    final absBalance = _totalBalance.abs();
    final formattedBalance = '\$${absBalance.toStringAsFixed(2)}';
    if (_totalBalance > 0) {
      return '$formattedBalance you are owed';
    } else if (_totalBalance < 0) {
      return '$formattedBalance you owe';
    } else {
      return 'All settled up!';
    }
  }

  // Determine if the total balance is positive, negative, or zero
  BalanceStatus getTotalBalanceStatus() {
    if (_totalBalance > 0) {
      return BalanceStatus.positive;
    } else if (_totalBalance < 0) {
      return BalanceStatus.negative;
    } else {
      return BalanceStatus.zero;
    }
  }
}

enum BalanceStatus { positive, negative, zero }
