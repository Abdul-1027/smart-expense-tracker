// screens/expenses/transaction_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final filters = ['All', 'Income', 'Expense', ...AppCategories.expenseCategories.take(5)];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () => provider.setSearchQuery(''))
                      : null,
                  filled: true, fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
                ),
              ),
            ),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = filters[i];
                  final active = provider.filterCategory == f ||
                      (f == 'All' && provider.filterCategory == null);
                  return FilterChip(
                    label: Text(f, style: TextStyle(fontSize: 12,
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                    selected: active,
                    onSelected: (_) => provider.setFilterCategory(f == 'All' ? null : f),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary,
                    side: BorderSide(color: active ? AppColors.primary : AppColors.border),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.filteredTransactions.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 64, color: AppColors.textHint),
        const SizedBox(height: 16),
        const Text('No transactions found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        if (provider.searchQuery.isNotEmpty || provider.filterCategory != null)
          TextButton(onPressed: provider.clearFilters, child: const Text('Clear filters', style: TextStyle(color: AppColors.primary))),
      ]))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.filteredTransactions.length,
        itemBuilder: (ctx, i) {
          final t = provider.filteredTransactions[i];
          final showDate = i == 0 ||
              provider.filteredTransactions[i-1].date.day != t.date.day;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text(_formatDateHeader(t.date),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: TransactionTile(
                  transaction: t,
                  onDelete: () => context.read<TransactionProvider>().deleteTransaction(t.id),
                  onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: t))),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) return 'Today';
    if (date.day == now.day - 1 && date.month == now.month) return 'Yesterday';
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}