import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceModel {
  final String id;
  final String userIdA; // First user
  final String userIdB; // Second user
  final double
  amount; // Positive means userA is owed by userB, negative means userA owes userB
  final DateTime lastUpdated;

  BalanceModel({
    required this.id,
    required this.userIdA,
    required this.userIdB,
    required this.amount,
    required this.lastUpdated,
  });

  // Create balance model from Firebase document
  factory BalanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BalanceModel(
      id: doc.id,
      userIdA: data['userIdA'] ?? '',
      userIdB: data['userIdB'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  // Convert balance model to JSON for Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'userIdA': userIdA,
      'userIdB': userIdB,
      'amount': amount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Create a copy with new values
  BalanceModel copyWith({
    String? id,
    String? userIdA,
    String? userIdB,
    double? amount,
    DateTime? lastUpdated,
  }) {
    return BalanceModel(
      id: id ?? this.id,
      userIdA: userIdA ?? this.userIdA,
      userIdB: userIdB ?? this.userIdB,
      amount: amount ?? this.amount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
