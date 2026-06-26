// models/transaction_model.dart

enum TransactionType { expense, income }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String description;
  final String paymentMethod;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.paymentMethod,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      paymentMethod: map['paymentMethod'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    String? description,
    String? paymentMethod,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}