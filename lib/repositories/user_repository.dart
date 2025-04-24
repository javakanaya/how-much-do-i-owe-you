import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc =
          await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      // Log error and rethrow
      rethrow;
    }
  }

  // Update existing user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      // Log error and rethrow
      rethrow;
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't rethrow - this is a background operation
    }
  }

  // Get users with optional search query and exclusion
  Future<List<UserModel>> getUsers(String query, {String? excludeUserId}) async {
    try {
      final List<UserModel> users;

      if (query.isEmpty) {
        // Get all users (limited to a reasonable number)
        final snapshot =
            await _firestore.collection(AppConstants.usersCollection).limit(20).get();

        users = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      } else {
        // Search for users by name or email
        users = await searchUsers(query);
      }

      // Exclude specific user if requested
      if (excludeUserId != null) {
        users.removeWhere((user) => user.id == excludeUserId);
      }

      return users;
    } catch (e) {
      // Log error and rethrow
      rethrow;
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final queryLowerCase = query.toLowerCase();

      // search by display name
      final nameQuery =
          await _firestore
              .collection(AppConstants.usersCollection)
              .where('displayName', isGreaterThanOrEqualTo: queryLowerCase)
              .where('displayName', isLessThanOrEqualTo: '$queryLowerCase\uf8ff')
              .get();

      // search by email
      final emailQuery =
          await _firestore
              .collection(AppConstants.usersCollection)
              .where('email', isGreaterThanOrEqualTo: queryLowerCase)
              .where('email', isLessThanOrEqualTo: '$queryLowerCase\uf8ff')
              .get();

      // Combine results and remove duplicates
      final Set<String> userIds = {};
      final List<UserModel> results = [];

      for (final doc in nameQuery.docs) {
        final user = UserModel.fromFirestore(doc);
        if (!userIds.contains(user.id)) {
          results.add(user);
          userIds.add(user.id);
        }
      }

      for (final doc in emailQuery.docs) {
        final user = UserModel.fromFirestore(doc);
        if (!userIds.contains(user.id)) {
          results.add(user);
          userIds.add(user.id);
        }
      }

      return results;
    } catch (e) {
      // Log error and rethrow
      rethrow;
    }
  }
}
