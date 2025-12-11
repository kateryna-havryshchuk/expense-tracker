import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  late final FirebaseStorage _storage;

  StorageRepository() {
    final storageApp = Firebase.app('storageApp');
    _storage = FirebaseStorage.instanceFor(app: storageApp);
  }

  Future<String> uploadUserAvatar(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('avatars/$userId.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      final ref = _storage.ref().child('avatars/$userId.jpg');
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  Future<String> uploadExportFile(String userId, File file) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref().child('exports/$userId/$timestamp.csv');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload export: $e');
    }
  }
}