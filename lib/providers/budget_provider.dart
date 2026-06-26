// providers/budget_provider.dart

import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../utils/database_helper.dart';

class BudgetProvider with ChangeNotifier {
  final _db = DatabaseHelper();

  List<BudgetModel> _budgets = [];

  List<BudgetModel> get budgets => _budgets;

  BudgetModel? get totalBudget {
    try {
      return _budgets.firstWhere((b) => b.category == 'total');
    } catch (_) {
      return null;
    }
  }

  double? getCategoryLimit(String category) {
    try {
      return _budgets.firstWhere((b) => b.category == category).limit;
    } catch (_) {
      return null;
    }
  }

  Future<void> loadBudgets() async {
    final now = DateTime.now();
    _budgets = await _db.getBudgetsForMonth(now.month, now.year);
    notifyListeners();
  }

  Future<void> setTotalBudget(double amount) async {
    final now = DateTime.now();
    final budget = BudgetModel(
      id: 'total_${now.month}_${now.year}',
      category: 'total',
      limit: amount,
      month: now.month,
      year: now.year,
    );
    await _db.insertOrUpdateBudget(budget);
    await loadBudgets();
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    final now = DateTime.now();
    final budget = BudgetModel(
      id: '${category}_${now.month}_${now.year}',
      category: category,
      limit: amount,
      month: now.month,
      year: now.year,
    );
    await _db.insertOrUpdateBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    await loadBudgets();
  }

  bool isTotalBudgetWarning(double spent) {
    final tb = totalBudget;
    if (tb == null) return false;
    return spent >= tb.limit * 0.9;
  }
}