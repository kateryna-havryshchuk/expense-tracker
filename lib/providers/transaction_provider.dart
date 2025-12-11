import 'package:expense_tracker/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart';
import '../repositories/transactions_repository.dart';
import '../repositories/budgets_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsRepository _repository;
  final BudgetsRepository _budgetsRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TransactionProvider(this._repository, this._budgetsRepository);

  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  
  String _currentFilter = 'All'; 
  String? _selectedCategory; 
  DateTime? _selectedDate;

  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;
  String? get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchTransactions() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _allTransactions = await _repository.getUserTransactions(userId);
      _applyFilter();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void setCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _applyFilter();
    notifyListeners();
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    _applyFilter();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel newTransaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _repository.addTransaction(userId, newTransaction);
      
      if (newTransaction.type == 'expense') {
        await _updateBudgetSpent(userId, newTransaction.categoryId, newTransaction.amount, isAdding: true);
      }
      
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _repository.updateTransaction(userId, transaction);
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final transaction = _allTransactions.firstWhere((t) => t.id == transactionId);
      
      await _repository.deleteTransaction(userId, transactionId);
      
      if (transaction.type == 'expense') {
        await _updateBudgetSpent(userId, transaction.categoryId, transaction.amount, isAdding: false);
      }
      
      await fetchTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<void> _updateBudgetSpent(String userId, String categoryId, double amount, {required bool isAdding}) async {
    try {
      final now = DateTime.now();
      final currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      
      final budgets = await _budgetsRepository.getUserBudgets(userId);
      
      final budget = budgets.where((b) => 
        b.categoryId == categoryId && b.month == currentMonth
      ).firstOrNull;
      
      if (budget != null) {
        final newSpent = isAdding 
          ? budget.spent + amount 
          : (budget.spent - amount).clamp(0.0, double.infinity);
        
        final updatedBudget = Budget(
          id: budget.id,
          categoryId: budget.categoryId,
          month: budget.month,
          limit: budget.limit,
          spent: newSpent,
          createdAt: budget.createdAt,
        );
        
        await _budgetsRepository.updateBudget(userId, updatedBudget);
      }
    } catch (e) {
      debugPrint('Error updating budget spent: $e');
    }
  }

  void _applyFilter() {
    _filteredTransactions = _allTransactions.where((t) {
      final filterMatch = _currentFilter == 'All' ||
          (_currentFilter == 'income' && t.type == 'income') ||
          (_currentFilter == 'expense' && t.type == 'expense');
      
      final categoryMatch = _selectedCategory == null || t.categoryId == _selectedCategory;
      
      final dateMatch = _selectedDate == null || 
          (t.date.year == _selectedDate!.year &&
           t.date.month == _selectedDate!.month &&
           t.date.day == _selectedDate!.day);
      
      return filterMatch && categoryMatch && dateMatch;
    }).toList();
  }
}