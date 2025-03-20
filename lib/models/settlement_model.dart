// models/settlement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SettlementModel {
  final String settlementId;
  final String payerId;
  final String receiverId;
  final double amount;
  final DateTime date;
  final String status; // 'completed', 'pending', 'canceled'
  final List<String> transactionIds;

  SettlementModel({
    required this.settlementId,
    required this.payerId,
    required this.receiverId,
    required this.amount,
    required this.date,
    required this.status,
    required this.transactionIds,
  });

  // Convert SettlementModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'settlementId': settlementId,
      'payerId': payerId,
      'receiverId': receiverId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'status': status,
      'transactionIds': transactionIds,
    };
  }

  // Create SettlementModel from Firestore document
  factory SettlementModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> transactionList = [];
    if (data['transactionIds'] != null) {
      transactionList = List<String>.from(data['transactionIds']);
    }

    return SettlementModel(
      settlementId: doc.id,
      payerId: data['payerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      amount:
          (data['amount'] is int)
              ? (data['amount'] as int).toDouble()
              : data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      transactionIds: transactionList,
    );
  }

  // Create a copy of SettlementModel with some fields changed
  SettlementModel copyWith({
    String? settlementId,
    String? payerId,
    String? receiverId,
    double? amount,
    DateTime? date,
    String? status,
    List<String>? transactionIds,
  }) {
    return SettlementModel(
      settlementId: settlementId ?? this.settlementId,
      payerId: payerId ?? this.payerId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      transactionIds: transactionIds ?? this.transactionIds,
    );
  }
}
