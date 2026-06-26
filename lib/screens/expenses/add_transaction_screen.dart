// screens/expenses/add_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = AppCategories.expenseCategories.first;
  String _paymentMethod = AppCategories.paymentMethods.first;
  DateTime _date = DateTime.now();
  bool _loading = false;

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.transaction!;
      _type = t.type;
      _amountCtrl.text = t.amount.toString();
      _descCtrl.text = t.description;
      _category = t.category;
      _paymentMethod = t.paymentMethod;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _type == TransactionType.expense
          ? AppCategories.expenseCategories
          : AppCategories.incomeCategories;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final amount = double.parse(_amountCtrl.text.trim());
    final provider = context.read<TransactionProvider>();

    if (_isEdit) {
      await provider.updateTransaction(widget.transaction!.copyWith(
        type: _type,
        amount: amount,
        category: _category,
        description: _descCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        date: _date,
      ));
    } else {
      await provider.addTransaction(
        type: _type,
        amount: amount,
        category: _category,
        description: _descCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        date: _date,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                _TypeTab(
                  label: 'Expense',
                  icon: Icons.arrow_upward,
                  selected: _type == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: () => setState(() {
                    _type = TransactionType.expense;
                    _category = AppCategories.expenseCategories.first;
                  }),
                ),
                _TypeTab(
                  label: 'Income',
                  icon: Icons.arrow_downward,
                  selected: _type == TransactionType.income,
                  color: AppColors.income,
                  onTap: () => setState(() {
                    _type = TransactionType.income;
                    _category = AppCategories.incomeCategories.first;
                  }),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Amount
            _buildCard(children: [
              _label('Amount (Rs)'),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: InputBorder.none,
                  prefixText: 'Rs ',
                  prefixStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  if (double.parse(v) <= 0) return 'Amount must be greater than 0';
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 12),

            // Category
            _buildCard(children: [
              _label('Category'),
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : _categories.first,
                decoration: const InputDecoration(border: InputBorder.none),
                items: _categories.map((c) => DropdownMenuItem(
                  value: c,
                  child: Row(children: [
                    Icon(AppCategories.getCategoryIcon(c), size: 18,
                        color: AppCategories.getCategoryColor(c)),
                    const SizedBox(width: 8),
                    Text(c),
                  ]),
                )).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ]),
            const SizedBox(height: 12),

            // Description
            _buildCard(children: [
              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  hintText: 'What was this for?',
                  border: InputBorder.none,
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Description is required' : null,
              ),
            ]),
            const SizedBox(height: 12),

            // Payment Method
            _buildCard(children: [
              _label('Payment Method'),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(border: InputBorder.none),
                items: AppCategories.paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
            ]),
            const SizedBox(height: 12),

            // Date
            _buildCard(children: [
              _label('Date'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: Text(DateFormat('dd MMM yyyy, EEEE').format(_date)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: _pickDate,
              ),
            ]),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == TransactionType.expense
                      ? AppColors.expense
                      : AppColors.income,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text(
                  _isEdit
                      ? 'Update Transaction'
                      : 'Add ${_type == TransactionType.expense ? "Expense" : "Income"}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary));
}

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }
}