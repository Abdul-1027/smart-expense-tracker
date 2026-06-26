// models/budget_model.dart

class BudgetModel {
  final String id;
  final String category; // 'total' for overall monthly budget
  final double limit;
  final int month; // 1-12
  final int year;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limit: map['limit'],
      month: map['month'],
      year: map['year'],
    );
  }
}