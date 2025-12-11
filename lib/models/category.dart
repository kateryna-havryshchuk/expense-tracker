import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? color;  
  final String? icon;   

  Category({
    required this.id,
    required this.name,
    this.color,
    this.icon,
  });

  factory Category.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Category(
      id: doc.id,
      name: data['name'] as String,
      color: data['color'] as String?,
      icon: data['icon'] as String?,
    );
  }
}
