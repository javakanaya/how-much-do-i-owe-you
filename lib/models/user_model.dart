import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastActive;
  final int totalPoints;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastActive,
    this.totalPoints = 0,
  });

  // Converts Firestore data to a UserModel object
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      totalPoints: data['totalPoints'] ?? 0,
    );
  }

  // Converts a UserModel object to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'totalPoints': totalPoints,
    };
  }
}
