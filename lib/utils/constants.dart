import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6200EA);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFEF5350);
  static const Color profit = Color(0xFF2196F3);
}

class AppStrings {
  static const String appName = 'Profit & Expense Analyzer';
  static const String databaseName = 'expense_tracker.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String tableUsers = 'users';
  static const String tableIncome = 'income';
  static const String tableExpense = 'expenses';
  static const String tableInventory = 'inventory';
  static const String tableBudget = 'budgets';
  static const String tableCategory = 'categories';
  static const String tableGST = 'gst_calculations';
  
  // Messages
  static const String loginSuccess = 'Login successful!';
  static const String loginFailed = 'Invalid credentials';
  static const String signupSuccess = 'Account created successfully!';
  static const String signupFailed = 'Registration failed';
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
}

// Default categories
class DefaultCategories {
  static const List<String> incomeCategories = [
    'Sales',
    'Services',
    'Investment',
    'Other Income',
  ];
  
  static const List<String> expenseCategories = [
    'Rent',
    'Utilities',
    'Salaries',
    'Raw Materials',
    'Marketing',
    'Transportation',
    'Maintenance',
    'Other Expenses',
  ];
}
