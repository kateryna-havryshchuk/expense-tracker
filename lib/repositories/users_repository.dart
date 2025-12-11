import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

abstract class UsersRepository {
  Future<UserProfile?> getCurrentUserProfile();
  Future<void> createOrUpdateUserProfile(UserProfile profile);
}

class FirestoreUsersRepository implements UsersRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromDoc(doc);
  }

  @override
  Future<void> createOrUpdateUserProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.id).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }
}
