import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../repositories/storage_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  final StorageRepository _storageRepo = StorageRepository();
  
  SettingsProvider(this._prefs) {
    _loadSettings();
    _initAuthListener();
  }

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String? _error;
  String? _userAvatarUrl;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String? get error => _error;
  String? get userAvatarUrl => _userAvatarUrl;

  void _initAuthListener() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        _userEmail = user.email ?? '';
        await _loadUserProfileFromFirestore();
      } else {
        _userAvatarUrl = null;
        _userName = '';
        _userEmail = '';
        _userPhone = '';
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfileFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _userName = data['name'] ?? user.displayName ?? '';
        _userAvatarUrl = data['avatarUrl']; 
        _userPhone = _prefs.getString('user_phone_${user.uid}') ?? ''; 
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserPhone(String phone) {
    _userPhone = phone;
    notifyListeners();
  }

  Future<void> savePersonalInfo() async {
    try {
      _error = null;
      final user = _auth.currentUser;
      
      if (user == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return;
      }

      await user.updateDisplayName(_userName);
      await user.reload();

      await _firestore.collection('users').doc(user.uid).update({
        'name': _userName,
      });

      await _prefs.setString('user_phone_${user.uid}', _userPhone);

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e.code);
      notifyListeners();
    } catch (e) {
      _error = 'Error saving info: ${e.toString()}';
      notifyListeners();
    }
  }

  bool _biometricsEnabled = false;
  bool get biometricsEnabled => _biometricsEnabled;

  void toggleBiometrics(bool value) {
    _biometricsEnabled = value;
    _prefs.setBool('biometrics_enabled', value);
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _error = null;

      if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
        _error = 'All fields are required';
        notifyListeners();
        return false;
      }

      if (newPassword != confirmPassword) {
        _error = 'Passwords do not match';
        notifyListeners();
        return false;
      }

      if (newPassword.length < 6) {
        _error = 'New password must be at least 6 characters';
        notifyListeners();
        return false;
      }

      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        _error = 'User not authenticated';
        notifyListeners();
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Password change failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _error = null;

      if (email.isEmpty) {
        _error = 'Email is required';
        notifyListeners();
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Reset failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  String _selectedCurrency = 'USD';
  bool _isThemeDark = false;
  bool _isNotificationsOn = true;
  bool _isSyncOn = true;

  String get selectedCurrency => _selectedCurrency;
  bool get isThemeDark => _isThemeDark;
  bool get isNotificationsOn => _isNotificationsOn;
  bool get isSyncOn => _isSyncOn;

  void setCurrency(String currency) {
    _selectedCurrency = currency;
    _prefs.setString('selected_currency', currency);
    notifyListeners();
  }

  void toggleTheme(bool value) {
    _isThemeDark = value;
    _prefs.setBool('is_theme_dark', value);
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _isNotificationsOn = value;
    _prefs.setBool('is_notifications_on', value);
    notifyListeners();
  }

  void toggleSync() {
    _isSyncOn = !_isSyncOn;
    _prefs.setBool('is_sync_on', _isSyncOn);
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final user = _auth.currentUser;
    
    if (user != null) {
      _userEmail = user.email ?? '';
      _userPhone = _prefs.getString('user_phone_${user.uid}') ?? '';
      await _loadUserProfileFromFirestore();
    }
    
    _selectedCurrency = _prefs.getString('selected_currency') ?? 'USD';
    _isThemeDark = _prefs.getBool('is_theme_dark') ?? false;
    _isNotificationsOn = _prefs.getBool('is_notifications_on') ?? true;
    _isSyncOn = _prefs.getBool('is_sync_on') ?? true; 
    _biometricsEnabled = _prefs.getBool('biometrics_enabled') ?? false;
    
    notifyListeners();
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Current password is incorrect';
      case 'user-not-found':
        return 'User not found';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> uploadAvatar(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      _error = null;
      
      final downloadUrl = await _storageRepo.uploadUserAvatar(
        user.uid,
        imageFile,
      );

      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': downloadUrl,
      });
      
      _userAvatarUrl = downloadUrl;
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to upload avatar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      await uploadAvatar(File(pickedFile.path));
    }
  }
}