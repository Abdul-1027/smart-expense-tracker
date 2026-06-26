// screens/budget/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProv = context.watch<BudgetProvider>();
    final txnProv = context.watch<TransactionProvider>();
    final fmt = NumberFormat('#,###', 'en_US');
    final catExpenses = txnProv.thisMonthExpenseByCategory;
    final totalBudget = budgetProv.totalBudget;
    final monthSpent = txnProv.thisMonthExpense;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budget Planner'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary),
            onPressed: () =>
                _showSetBudgetDialog(context, budgetProv),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Monthly Budget',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  totalBudget != null
                      ? Text(
                    'Rs ${fmt.format(totalBudget.limit)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  )
                      : const Text('Not set',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 22)),
                  const SizedBox(height: 16),
                  if (totalBudget != null) ...[
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: Rs ${fmt.format(monthSpent)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        Text(
                          'Left: Rs ${fmt.format(totalBudget.limit - monthSpent)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (monthSpent / totalBudget.limit)
                            .clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(
                          monthSpent >= totalBudget.limit
                              ? AppColors.expense
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        _showSetBudgetDialog(context, budgetProv),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        totalBudget != null
                            ? 'Update Budget'
                            : 'Set Monthly Budget',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Category Budgets',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            ...AppCategories.expenseCategories.map((cat) {
              final spent = catExpenses[cat] ?? 0;
              final budgetLimit =
              budgetProv.getCategoryLimit(cat);
              final pct = budgetLimit != null && budgetLimit > 0
                  ? (spent / budgetLimit).clamp(0.0, 1.0)
                  : null;
              final color = AppCategories.getCategoryColor(cat);
              final icon = AppCategories.getCategoryIcon(cat);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                        Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(cat,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                            Text(
                              spent > 0
                                  ? 'Rs ${fmt.format(spent)} spent'
                                  : 'No expenses',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _showCategoryBudgetDialog(
                                context, budgetProv, cat),
                        child: Text(
                          budgetLimit != null
                              ? 'Edit'
                              : 'Set limit',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13),
                        ),
                      ),
                    ]),
                    if (budgetLimit != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rs ${fmt.format(spent)} / Rs ${fmt.format(budgetLimit)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          Text(
                            '${((pct ?? 0) * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (pct ?? 0) >= 1.0
                                  ? AppColors.expense
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct ?? 0,
                          minHeight: 6,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(
                            (pct ?? 0) >= 1.0
                                ? AppColors.expense
                                : color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog(
      BuildContext context, BudgetProvider provider) {
    final ctrl = TextEditingController(
        text: provider.totalBudget?.limit.toStringAsFixed(0) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Budget Amount (Rs)',
              prefixText: 'Rs '),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                provider.setTotalBudget(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCategoryBudgetDialog(BuildContext context,
      BudgetProvider provider, String category) {
    final existing = provider.getCategoryLimit(category);
    final ctrl = TextEditingController(
        text: existing?.toStringAsFixed(0) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Budget for $category'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Limit (Rs)', prefixText: 'Rs '),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                provider.setCategoryBudget(category, val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}