import 'package:expense_tracker/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/services/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthProvider(this._authRepository) {
    _initializeAuthListener();
  }

  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String get userDisplayName => _currentUser?.displayName ?? 'Guest';
  String get userEmail => _currentUser?.email ?? '';
  String? get userPhotoUrl => _currentUser?.photoURL;

  void _initializeAuthListener() {
    _currentUser = _firebaseAuth.currentUser;
    
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.signIn(email: email, password: password);
      _currentUser = _firebaseAuth.currentUser;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e.code);
      return false;
    } catch (e) {
      _error = AppStrings.errorUnknown;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = _firebaseAuth.currentUser;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleFirebaseError(e.code);
      return false;
    } catch (e) {
      _error = AppStrings.errorUnknown;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.signInWithGoogle();
      _currentUser = _firebaseAuth.currentUser;
      return true;
    } catch (e) {
      _error = AppStrings.errorGoogleSignIn;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      return true;
    } catch (e) {
      _error = 'Sign out failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return AppStrings.errorUserNotFound;
      case 'wrong-password':
        return AppStrings.errorWrongPassword;
      case 'invalid-credential':
        return AppStrings.errorInvalidCredential;

      case 'weak-password':
        return AppStrings.errorWeakPassword;
      case 'email-already-in-use':
        return AppStrings.errorEmailInUse;
      case 'invalid-email':
        return AppStrings.errorInvalidEmail;

      case 'user-disabled':
        return 'User account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed';

      default:
        return AppStrings.errorUnknown;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}