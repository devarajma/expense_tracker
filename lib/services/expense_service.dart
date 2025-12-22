import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/utils/constants.dart';

class ExpenseService {
  final _db = DatabaseHelper.instance;

  // Add expense
  Future<int> addExpense(ExpenseModel expense) async {
    return await _db.insert(AppStrings.tableExpense, expense.toMap());
  }

  // Update expense
  Future<bool> updateExpense(ExpenseModel expense) async {
    final result = await _db.update(AppStrings.tableExpense, expense.toMap());
    return result > 0;
  }

  // Delete expense
  Future<bool> deleteExpense(int id) async {
    final result = await _db.delete(AppStrings.tableExpense, id);
    return result > 0;
  }

  // Get all expenses for user
  Future<List<ExpenseModel>> getAllExpenses(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableExpense,
      'userId = ?',
      [userId],
    );
    return results.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  // Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allExpenses = await getAllExpenses(userId);
    return allExpenses.where((expense) {
      return !expense.date.isBefore(startDate) &&
          !expense.date.isAfter(endDate);
    }).toList();
  }

  // Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory({
    required int userId,
    required String category,
  }) async {
    final results = await _db.queryWhere(
      AppStrings.tableExpense,
      'userId = ? AND category = ?',
      [userId, category],
    );
    return results.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  // Get total expenses for period
  Future<double> getTotalExpenses({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final expenses = await getExpensesByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get daily total
  Future<double> getDailyTotal(int userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return await getTotalExpenses(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get weekly total
  Future<double> getWeeklyTotal(int userId, DateTime date) async {
    final weekday = date.weekday;
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return await getTotalExpenses(
      userId: userId,
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  // Get monthly total
  Future<double> getMonthlyTotal(int userId, DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    return await getTotalExpenses(
      userId: userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }
}
