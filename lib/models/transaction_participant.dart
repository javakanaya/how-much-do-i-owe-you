import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionParticipant {
  final String userId;
  final double owedAmount;
  final bool isPayer;
  final bool isSettled;
  final DateTime? settledAt;

  TransactionParticipant({
    required this.userId,
    required this.owedAmount,
    required this.isPayer,
    required this.isSettled,
    this.settledAt,
  });

  // Create from map
  factory TransactionParticipant.fromFirestore(Map<String, dynamic> map) {
    return TransactionParticipant(
      userId: map['userId'] ?? '',
      owedAmount: (map['owedAmount'] ?? 0.0).toDouble(),
      isPayer: map['isPayer'] ?? false,
      isSettled: map['isSettled'] ?? false,
      settledAt:
          map['settledAt'] != null ? (map['settledAt'] as Timestamp).toDate() : null,
    );
  }

  // Convert to map
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userId': userId,
      'owedAmount': owedAmount,
      'isPayer': isPayer,
      'isSettled': isSettled,
    };

    if (settledAt != null) {
      map['settledAt'] = Timestamp.fromDate(settledAt!);
    }

    return map;
  }
}
