import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _ensureUserProfile(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': user.email ?? '',
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'currency': 'USD',
        'role': 'user',
        'avatarUrl': user.photoURL, 
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'email': user.email ?? '',
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      });
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        
        await _ensureUserProfile(credential.user!);
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Unknown registration error: ${e.toString()}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _ensureUserProfile(userCredential.user!);
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Google sign-in error: ${e.toString()}');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _ensureUserProfile(userCredential.user!);
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Unknown sign-in error: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out error: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Password reset error: ${e.toString()}');
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}