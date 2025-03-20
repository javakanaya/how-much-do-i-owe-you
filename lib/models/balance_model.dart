// models/balance_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceModel {
  final String balanceId;
  final String userIdA;
  final String userIdB;
  final double amount; // Positive if A owes B, negative if B owes A
  final DateTime lastUpdated;

  BalanceModel({
    required this.balanceId,
    required this.userIdA,
    required this.userIdB,
    required this.amount,
    required this.lastUpdated,
  });

  // Convert BalanceModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'balanceId': balanceId,
      'userIdA': userIdA,
      'userIdB': userIdB,
      'amount': amount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Create BalanceModel from Firestore document
  factory BalanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return BalanceModel(
      balanceId: doc.id,
      userIdA: data['userIdA'] ?? '',
      userIdB: data['userIdB'] ?? '',
      amount:
          (data['amount'] is int)
              ? (data['amount'] as int).toDouble()
              : data['amount'] ?? 0.0,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Create a copy of BalanceModel with some fields changed
  BalanceModel copyWith({
    String? balanceId,
    String? userIdA,
    String? userIdB,
    double? amount,
    DateTime? lastUpdated,
  }) {
    return BalanceModel(
      balanceId: balanceId ?? this.balanceId,
      userIdA: userIdA ?? this.userIdA,
      userIdB: userIdB ?? this.userIdB,
      amount: amount ?? this.amount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper to determine if the specified user is a debtor (owes money)
  bool isDebtor(String userId) {
    if (userId == userIdA) {
      return amount > 0; // A owes B
    } else if (userId == userIdB) {
      return amount < 0; // B owes A
    }
    return false;
  }

  // Helper to get amount for a specific user perspective
  double getAmountForUser(String userId) {
    if (userId == userIdA) {
      return amount; // Positive if A owes B
    } else if (userId == userIdB) {
      return -amount; // Negative if B owes A (flip sign)
    }
    return 0.0;
  }

  // Helper to get the other user ID
  String getOtherUserId(String userId) {
    return userId == userIdA ? userIdB : userIdA;
  }
}
