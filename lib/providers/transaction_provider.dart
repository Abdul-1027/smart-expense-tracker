// providers/transaction_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../utils/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final _db = DatabaseHelper();
  final _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  String _searchQuery = '';
  String? _filterCategory;
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get filterCategory => _filterCategory;

  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> list = List.from(_transactions);

    if (_searchQuery.isNotEmpty) {
      list = list.where((t) =>
      t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_filterCategory != null && _filterCategory != 'All') {
      if (_filterCategory == 'Income') {
        list = list.where((t) => t.type == TransactionType.income).toList();
      } else if (_filterCategory == 'Expense') {
        list = list.where((t) => t.type == TransactionType.expense).toList();
      } else {
        list = list.where((t) => t.category == _filterCategory).toList();
      }
    }

    return list;
  }

  List<TransactionModel> get recentTransactions =>
      _transactions.take(10).toList();

  double get totalIncome =>
      _transactions.where((t) => t.type == TransactionType.income)
          .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      _transactions.where((t) => t.type == TransactionType.expense)
          .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  double get thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.expense &&
        t.date.month == now.month && t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get thisMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.type == TransactionType.income &&
        t.date.month == now.month && t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, double> get thisMonthExpenseByCategory {
    final now = DateTime.now();
    final map = <String, double>{};
    for (final t in _transactions.where((t) =>
    t.type == TransactionType.expense &&
        t.date.month == now.month && t.date.year == now.year)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, double> get monthlyTrend {
    final now = DateTime.now();
    final map = <String, double>{};
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = _monthKey(month);
      map[key] = 0;
    }
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      final key = _monthKey(t.date);
      if (map.containsKey(key)) {
        map[key] = (map[key] ?? 0) + t.amount;
      }
    }
    return map;
  }

  String _monthKey(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.year.toString().substring(2)}';
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _db.getAllTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required String category,
    required String description,
    required String paymentMethod,
    required DateTime date,
  }) async {
    final txn = TransactionModel(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      category: category,
      description: description,
      paymentMethod: paymentMethod,
      date: date,
    );
    await _db.insertTransaction(txn);
    _transactions.insert(0, txn);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel updated) async {
    await _db.updateTransaction(updated);
    final idx = _transactions.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      _transactions[idx] = updated;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = null;
    notifyListeners();
  }
}