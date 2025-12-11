import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';

abstract class BudgetsRepository {
  Future<List<Budget>> getUserBudgets(String userId);
  Future<void> addBudget(String userId, Budget budget);
  Future<void> updateBudget(String userId, Budget budget);
  Future<void> deleteBudget(String userId, String id);
}

class FirestoreBudgetsRepository implements BudgetsRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) {
    return _db.collection('users').doc(userId).collection('budgets');
  }

  @override
  Future<List<Budget>> getUserBudgets(String userId) async {
    final snap = await _col(userId)
        .orderBy('month', descending: true)
        .get();
    return snap.docs.map(Budget.fromDoc).toList();
  }

  @override
  Future<void> addBudget(String userId, Budget budget) async {
    await _col(userId).add(budget.toMap());
  }

  @override
  Future<void> updateBudget(String userId, Budget budget) async {
    await _col(userId).doc(budget.id).update(budget.toMap());
  }

  @override
  Future<void> deleteBudget(String userId, String id) async {
    await _col(userId).doc(id).delete();
  }
}
