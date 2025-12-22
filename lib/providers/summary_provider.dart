import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/services/income_service.dart';
import 'package:expense_tracker/services/expense_service.dart';

// Service providers
final incomeServiceProvider = Provider((ref) => IncomeService());
final expenseServiceProvider = Provider((ref) => ExpenseService());

// Summary calculation
class DailySummary {
  final double totalIncome;
  final double totalExpense;
  final double profit;
  final DateTime date;

  DailySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.date,
  }) : profit = totalIncome - totalExpense;
}

// Daily summary provider
final dailySummaryProvider = FutureProvider.family<DailySummary, int>((ref, userId) async {
  final incomeService = ref.watch(incomeServiceProvider);
  final expenseService = ref.watch(expenseServiceProvider);
  
  final today = DateTime.now();
  final totalIncome = await incomeService.getDailyTotal(userId, today);
  final totalExpense = await expenseService.getDailyTotal(userId, today);
  
  return DailySummary(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    date: today,
  );
});

// Monthly summary provider
final monthlySummaryProvider = FutureProvider.family<DailySummary, int>((ref, userId) async {
  final incomeService = ref.watch(incomeServiceProvider);
  final expenseService = ref.watch(expenseServiceProvider);
  
  final today = DateTime.now();
  final totalIncome = await incomeService.getMonthlyTotal(userId, today);
  final totalExpense = await expenseService.getMonthlyTotal(userId, today);
  
  return DailySummary(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    date: today,
  );
});

// Profit data for charts
class ProfitData {
  final DateTime date;
  final double income;
  final double expense;
  final double profit;

  ProfitData({
    required this.date,
    required this.income,
    required this.expense,
  }) : profit = income - expense;
}

// Monthly profit chart data provider (last 6 months)
final monthlyProfitDataProvider = FutureProvider.family<List<ProfitData>, int>((ref, userId) async {
  final incomeService = ref.watch(incomeServiceProvider);
  final expenseService = ref.watch(expenseServiceProvider);
  
  final List<ProfitData> data = [];
  final now = DateTime.now();
  
  for (int i = 5; i >= 0; i--) {
    // Calculate the target month and handle year boundary crossing
    final totalMonths = (now.year * 12 + now.month) - i;
    final targetYear = (totalMonths - 1) ~/ 12;
    final targetMonth = ((totalMonths - 1) % 12) + 1;
    final date = DateTime(targetYear, targetMonth, 1);
    
    final income = await incomeService.getMonthlyTotal(userId, date);
    final expense = await expenseService.getMonthlyTotal(userId, date);
    
    data.add(ProfitData(
      date: date,
      income: income,
      expense: expense,
    ));
  }
  
  return data;
});

// Recent transactions provider (last 10 combined)
final recentTransactionsProvider = FutureProvider.family<List<dynamic>, int>((ref, userId) async {
  final incomeService = ref.watch(incomeServiceProvider);
  final expenseService = ref.watch(expenseServiceProvider);
  
  final incomes = await incomeService.getAllIncome(userId);
  final expenses = await expenseService.getAllExpenses(userId);
  
  // Combine and sort by date
  final combined = <dynamic>[...incomes, ...expenses];
  combined.sort((a, b) => b.date.compareTo(a.date));
  
  return combined.take(10).toList();
});
