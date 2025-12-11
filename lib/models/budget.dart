import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String categoryId;
  final String month; 
  final double limit;
  final double spent;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limit,
    required this.spent,
    required this.createdAt,
  });

  double get remaining => limit - spent;
  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
  bool get isExceeded => spent > limit;

  factory Budget.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Budget(
      id: doc.id,
      categoryId: data['categoryId'] as String,
      month: data['month'] as String,
      limit: (data['limit'] as num).toDouble(),
      spent: (data['spent'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'month': month,
      'limit': limit,
      'spent': spent,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
