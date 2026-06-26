// widgets/transaction_tile.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = t.type == TransactionType.income;
    final color = AppCategories.getCategoryColor(t.category);
    final fmt = NumberFormat('#,###', 'en_US');

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(AppCategories.getCategoryIcon(t.category),
            color: color, size: 22),
      ),
      title: Text(
        t.description,
        style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${t.category} · ${t.paymentMethod} · ${DateFormat('dd MMM').format(t.date)}',
        style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isIncome ? '+' : '-'} Rs ${fmt.format(t.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                size: 18, color: AppColors.textSecondary),
            onSelected: (v) {
              if (v == 'edit') onEdit?.call();
              if (v == 'delete') _confirmDelete(context);
            },
            itemBuilder: (_) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ]),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.expense),
                    SizedBox(width: 8),
                    Text('Delete',
                        style:
                        TextStyle(color: AppColors.expense)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}