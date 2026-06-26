// utils/constants.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1D9E75);
  static const Color primaryLight = Color(0xFFE1F5EE);
  static const Color primaryDark = Color(0xFF0F6E56);

  static const Color income = Color(0xFF1D9E75);
  static const Color expense = Color(0xFFE24B4A);
  static const Color warning = Color(0xFFBA7517);
  static const Color warningLight = Color(0xFFFAEEDA);

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE8ECEF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
}

class AppCategories {
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Health & Medical',
    'Bills & Utilities',
    'Entertainment',
    'Education',
    'Travel',
    'Groceries',
    'Rent',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Mobile Pay',
    'Other',
  ];

  static Color getCategoryColor(String category) {
    const colorMap = {
      'Food & Dining': Color(0xFFE24B4A),
      'Transport': Color(0xFF378ADD),
      'Shopping': Color(0xFFD4537E),
      'Health & Medical': Color(0xFF1D9E75),
      'Bills & Utilities': Color(0xFFBA7517),
      'Entertainment': Color(0xFF7F77DD),
      'Education': Color(0xFF5DCAA5),
      'Travel': Color(0xFF63AF8A),
      'Groceries': Color(0xFF639922),
      'Rent': Color(0xFF888780),
      'Salary': Color(0xFF1D9E75),
      'Freelance': Color(0xFF5DCAA5),
      'Business': Color(0xFF3B6D11),
      'Investment': Color(0xFF378ADD),
      'Gift': Color(0xFFD4537E),
    };
    return colorMap[category] ?? const Color(0xFF888780);
  }

  static IconData getCategoryIcon(String category) {
    const iconMap = {
      'Food & Dining': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Health & Medical': Icons.local_hospital,
      'Bills & Utilities': Icons.bolt,
      'Entertainment': Icons.movie,
      'Education': Icons.school,
      'Travel': Icons.flight,
      'Groceries': Icons.local_grocery_store,
      'Rent': Icons.home,
      'Salary': Icons.account_balance_wallet,
      'Freelance': Icons.laptop,
      'Business': Icons.business_center,
      'Investment': Icons.trending_up,
      'Gift': Icons.card_giftcard,
    };
    return iconMap[category] ?? Icons.category;
  }
}

class AppStrings {
  static const String appName = 'SpendSmart';
  static const String tagline = 'Your Personal Finance Manager';
}