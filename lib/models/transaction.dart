import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String categoryId;
  final String type;
  final String subtitle; // ✅ Особисте пояснення
  final String? note;    // ✅ Детальний опис
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.subtitle,
    required this.date,
    required this.createdAt,
    this.note,
  });

  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['categoryId'],
      type: data['type'],
      subtitle: data['subtitle'] ?? 'No description',
      note: data['note'],
      date: (data['date'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'categoryId': categoryId,
      'type': type,
      'subtitle': subtitle,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
