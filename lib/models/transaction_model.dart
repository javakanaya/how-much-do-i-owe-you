// models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String description;
  final double amount;
  final DateTime date;
  final String payerId;
  final String categoryId;
  final String status; // 'active', 'settled', 'canceled'
  final List<String> participants; // List of participant IDs

  TransactionModel({
    required this.transactionId,
    required this.description,
    required this.amount,
    required this.date,
    required this.payerId,
    required this.categoryId,
    required this.status,
    required this.participants,
  });

  // Convert TransactionModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'payerId': payerId,
      'categoryId': categoryId,
      'status': status,
      'participants': participants,
    };
  }

  // Create TransactionModel from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> participantsList = [];
    if (data['participants'] != null) {
      participantsList = List<String>.from(data['participants']);
    }

    return TransactionModel(
      transactionId: doc.id,
      description: data['description'] ?? '',
      amount:
          (data['amount'] is int)
              ? (data['amount'] as int).toDouble()
              : data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      payerId: data['payerId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      status: data['status'] ?? 'active',
      participants: participantsList,
    );
  }

  // Create a copy of TransactionModel with some fields changed
  TransactionModel copyWith({
    String? transactionId,
    String? description,
    double? amount,
    DateTime? date,
    String? payerId,
    String? categoryId,
    String? status,
    List<String>? participants,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      payerId: payerId ?? this.payerId,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      participants: participants ?? this.participants,
    );
  }
}
