import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart'; //

@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
User? currentUser(Ref ref) {
  return FirebaseAuth.instance.currentUser;
}

// Provider for auth error state (null means no error)
@riverpod
class AuthError extends _$AuthError {
  @override
  String? build() => null; // Initially no error

  // Method to update error state
  void setError(String error) => state = error;

  // Method to clear error
  void clearError() => state = null;
}

@riverpod
class AuthService extends _$AuthService {
  final _auth = FirebaseAuth.instance;

  @override
  void build() {}

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ref.read(authErrorProvider.notifier).clearError();
      return result.user;
    } on FirebaseAuthException catch (e) {
      ref.read(authErrorProvider.notifier).setError(_mapAuthError(e.code));
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with display name
      await result.user?.updateDisplayName(displayName);

      ref.read(authErrorProvider.notifier).clearError();
      return result.user;
    } on FirebaseAuthException catch (e) {
      ref.read(authErrorProvider.notifier).setError(_mapAuthError(e.code));
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Map Firebase error codes to user-friendly messages
  String _mapAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
