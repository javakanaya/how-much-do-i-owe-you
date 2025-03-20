// models/participant_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantModel {
  final String userId;
  final String transactionId;
  final double owedAmount;
  final bool isPayer;
  final bool isSettled;
  final DateTime? settledAt;

  ParticipantModel({
    required this.userId,
    required this.transactionId,
    required this.owedAmount,
    this.isPayer = false,
    this.isSettled = false,
    this.settledAt,
  });

  // Convert ParticipantModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'transactionId': transactionId,
      'owedAmount': owedAmount,
      'isPayer': isPayer,
      'isSettled': isSettled,
      'settledAt':
          settledAt != null ? Timestamp.fromDate(settledAt!) : null,
    };
  }

  // Create ParticipantModel from Firestore document
  factory ParticipantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ParticipantModel(
      userId: data['userId'] ?? '',
      transactionId: data['transactionId'] ?? '',
      owedAmount:
          (data['owedAmount'] is int)
              ? (data['owedAmount'] as int).toDouble()
              : data['owedAmount'] ?? 0.0,
      isPayer: data['isPayer'] ?? false,
      isSettled: data['isSettled'] ?? false,
      settledAt:
          data['settledAt'] != null
              ? (data['settledAt'] as Timestamp).toDate()
              : null,
    );
  }

  // Create a copy of ParticipantModel with some fields changed
  ParticipantModel copyWith({
    String? userId,
    String? transactionId,
    double? owedAmount,
    bool? isPayer,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return ParticipantModel(
      userId: userId ?? this.userId,
      transactionId: transactionId ?? this.transactionId,
      owedAmount: owedAmount ?? this.owedAmount,
      isPayer: isPayer ?? this.isPayer,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}
