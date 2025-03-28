import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'lastActive': FieldValue.serverTimestamp()});
    } catch (e) {
      // Log error but don't rethrow - this is a background operation
    }
  }
}
