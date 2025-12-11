import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;     
  final String email;
  final String name;
  final String currency;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.currency,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
  });

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      email: data['email'] as String,
      name: data['name'] as String,
      currency: data['currency'] as String,
      role: data['role'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'currency': currency,
      'role': role,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
