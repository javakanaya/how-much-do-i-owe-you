// services/auth_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // In your getCurrentUserModel method
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(currentUser!.uid)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last active timestamp
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(result.user!.uid)
          .update({'lastActive': FieldValue.serverTimestamp()});

      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    File? profileImage,
  ) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Upload profile image if available
        String? photoURL;
        if (profileImage != null) {
          photoURL = await _uploadProfileImage(user.uid, profileImage);
        }

        // Update user profile in Auth
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }

        // Create user document in Firestore
        await _createUserDocument(user.uid, email, displayName, photoURL);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Upload profile image to Firebase Storage
  Future<String?> _uploadProfileImage(String userId, File imageFile) async {
    try {
      // Create a reference to the user's profile image
      Reference ref = _storage.ref().child('profile_images/$userId.jpg');

      // Upload file
      await ref.putFile(imageFile);

      // Get download URL
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    String userId,
    String email,
    String displayName,
    String? photoURL,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set({
            'userId': userId,
            'email': email,
            'displayName': displayName,
            'photoURL': photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastActive': FieldValue.serverTimestamp(),
            'totalPoints': 0,
          });
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
}
