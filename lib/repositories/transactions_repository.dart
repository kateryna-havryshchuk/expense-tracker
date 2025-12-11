import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/transaction.dart';

abstract class TransactionsRepository {
  Future<List<TransactionModel>> getUserTransactions(String userId);
  Future<void> addTransaction(String userId, TransactionModel t);
  Future<void> updateTransaction(String userId, TransactionModel t);
  Future<void> deleteTransaction(String userId, String id);
}

class FirestoreTransactionsRepository implements TransactionsRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) {
    return _db.collection('users').doc(userId).collection('transactions');
  }

  @override
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final snap =
        await _col(userId).orderBy('date', descending: true).get();
    return snap.docs.map(TransactionModel.fromDoc).toList();
  }

  @override
  Future<void> addTransaction(String userId, TransactionModel t) async {
    await _col(userId).add(t.toMap());
  }

  @override
  Future<void> updateTransaction(String userId, TransactionModel t) async {
    await _col(userId).doc(t.id).update(t.toMap());
  }

  @override
  Future<void> deleteTransaction(String userId, String id) async {
    await _col(userId).doc(id).delete();
  }
}
