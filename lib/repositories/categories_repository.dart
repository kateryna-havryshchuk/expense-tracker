import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(Map<String, dynamic> categoryData); 
}

class FirestoreCategoriesRepository implements CategoriesRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<List<Category>> getCategories() async {
    final snap = await _db.collection('categories').get();
    return snap.docs.map(Category.fromDoc).toList();
  }

  @override
  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    await _db.collection('categories').add(categoryData);
  }
}
