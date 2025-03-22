// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  AuthStatus _status = AuthStatus.loading;
  User? _user;
  UserModel? _userModel;
  String? _errorMessage;

  AuthProvider(this._authService) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

      if (user != null) {
        // Fetch user data from Firestore
        _fetchUserModel();
      } else {
        _userModel = null;
      }

      notifyListeners();
    });
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Fetch current user data from Firestore
  Future<void> _fetchUserModel() async {
    try {
      _userModel = await _authService.getCurrentUserModel();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _setErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register(
    String email,
    String password,
    String displayName,
    File? profileImage,
  ) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
        profileImage,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _setErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _authService.resetPassword(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Set error message based on Firebase exception
  void _setErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'No user found with this email.';
        break;
      case 'wrong-password':
        _errorMessage = 'Incorrect password.';
        break;
      case 'email-already-in-use':
        _errorMessage = 'This email is already registered.';
        break;
      case 'weak-password':
        _errorMessage = 'Password is too weak.';
        break;
      case 'invalid-email':
        _errorMessage = 'Invalid email address.';
        break;
      default:
        _errorMessage = e.message ?? 'An error occurred. Please try again.';
    }
  }
}
