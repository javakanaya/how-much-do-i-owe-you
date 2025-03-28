// services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      Query usersQuery = _firestore.collection(AppConstants.usersCollection);

      // If query is not empty, perform filtering
      if (query.trim().isNotEmpty) {
        // Convert query to lowercase for case-insensitive search
        final searchQuery = query.trim().toLowerCase();

        // Get users whose displayName contains the query
        final displayNameSnapshot =
            await usersQuery
                .where('displayName', isGreaterThanOrEqualTo: searchQuery)
                .where('displayName', isLessThanOrEqualTo: '$searchQuery\uf8ff')
                .limit(10)
                .get();

        // Get users whose email contains the query
        final emailSnapshot =
            await usersQuery
                .where('email', isGreaterThanOrEqualTo: searchQuery)
                .where('email', isLessThanOrEqualTo: '$searchQuery\uf8ff')
                .limit(10)
                .get();

        // Combine results, removing duplicates
        final Map<String, UserModel> userMap = {};

        for (var doc in displayNameSnapshot.docs) {
          final user = UserModel.fromFirestore(doc);
          userMap[user.id] = user;
        }

        for (var doc in emailSnapshot.docs) {
          final user = UserModel.fromFirestore(doc);
          userMap[user.id] = user;
        }

        return userMap.values.toList();
      } else {
        // If query is empty, get recent users (limit to 20)
        final snapshot =
            await usersQuery
                .orderBy('lastActive', descending: true)
                .limit(20)
                .get();

        return snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      debugPrint('Error searching users: $e');

      // For development - fallback to a simpler query if the above fails
      // (Firebase might not have the lowercase fields indexed)
      try {
        final snapshot =
            await _firestore
                .collection(AppConstants.usersCollection)
                .limit(20)
                .get();

        final users =
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

        // Manual filtering if query exists
        if (query.trim().isNotEmpty) {
          final searchQuery = query.trim().toLowerCase();
          return users
              .where(
                (user) =>
                    user.displayName.toLowerCase().contains(searchQuery) ||
                    user.email.toLowerCase().contains(searchQuery),
              )
              .toList();
        }

        return users;
      } catch (fallbackError) {
        debugPrint('Error in fallback search: $fallbackError');
        return [];
      }
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // Create or update lowercase fields for text search
  // This should be called when a user is created or updated
  Future<void> updateUserSearchFields(String userId) async {
    try {
      final userDoc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        final updates = <String, dynamic>{};

        if (data['displayName'] != null) {
          updates['displayName_lowercase'] =
              data['displayName'].toString().toLowerCase();
        }

        if (data['email'] != null) {
          updates['email_lowercase'] = data['email'].toString().toLowerCase();
        }

        if (updates.isNotEmpty) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userId)
              .update(updates);
        }
      }
    } catch (e) {
      debugPrint('Error updating user search fields: $e');
    }
  }
}
