import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget.dart';
import '../repositories/budgets_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetsRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BudgetProvider(this._repository);

  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  double get totalLimit => _budgets.fold(0, (sum, item) => sum + item.limit);
  double get totalSpent => _budgets.fold(0, (sum, item) => sum + item.spent);
  double get totalRemaining => totalLimit - totalSpent;
  double get totalPercentage => totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

  Future<void> fetchBudgets() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _budgets = await _repository.getUserBudgets(userId);
    } catch (e) {
      debugPrint('Error fetching budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(Budget budget) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _repository.addBudget(userId, budget);
      await fetchBudgets();
    } catch (e) {
      debugPrint('Error adding budget: $e');
    }
  }

  Future<void> updateBudget(Budget budget) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _repository.updateBudget(userId, budget);
      await fetchBudgets();
    } catch (e) {
      debugPrint('Error updating budget: $e');
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _repository.deleteBudget(userId, budgetId);
      await fetchBudgets();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
    }
  }
}