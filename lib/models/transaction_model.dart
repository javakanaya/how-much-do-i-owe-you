// models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_provider.dart';

class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String payerId;
  final String status; // 'active', 'settled', 'canceled'
  final List<TransactionParticipant> participants; // List of participant IDs

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.payerId,
    required this.status,
    required this.participants,
  });

  // Convert TransactionModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'payerId': payerId,
      'status': status,
      'participants': participants.map((p) => p.toFirestore()).toList(),
    };
  }

  // Create TransactionModel from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Convert participants data
    List<TransactionParticipant> participantsList = [];
    if (data['participants'] != null) {
      participantsList = List<TransactionParticipant>.from(
        (data['participants'] as List).map(
          (participant) => TransactionParticipant.fromFirestore(participant),
        ),
      );
    }

    return TransactionModel(
      id: doc.id,
      description: data['description'] ?? '',
      amount:
          (data['amount'] is int)
              ? (data['amount'] as int).toDouble()
              : data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      payerId: data['payerId'] ?? '',
      status: data['status'] ?? 'active',
      participants: participantsList,
    );
  }

  // Create a copy of TransactionModel with some fields changed
  TransactionModel copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? payerId,
    String? categoryId,
    String? status,
    List<TransactionParticipant>? participants,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      payerId: payerId ?? this.payerId,
      status: status ?? this.status,
      participants: participants ?? this.participants,
    );
  }
}
