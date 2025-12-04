import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/utils/constants.dart';

class BudgetService {
  final _db = DatabaseHelper.instance;
  final _expenseService = ExpenseService();

  // Set or update budget for month
  Future<bool> setBudget({
    required int userId,
    required double monthlyBudget,
    required int month,
    required int year,
  }) async {
    try {
      // Check if budget exists for this month
      final existing = await _db.queryWhere(
        AppStrings.tableBudget,
        'userId = ? AND month = ? AND year = ?',
        [userId, month, year],
      );

      // Calculate current spent amount from expenses
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      final spentAmount = await _expenseService.getTotalExpenses(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final budget = BudgetModel(
        id: existing.isNotEmpty ? existing.first['id'] as int : null,
        userId: userId,
        monthlyBudget: monthlyBudget,
        spentAmount: spentAmount,
        month: month,
        year: year,
      );

      if (existing.isEmpty) {
        await _db.insert(AppStrings.tableBudget, budget.toMap());
      } else {
        await _db.update(AppStrings.tableBudget, budget.toMap());
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get budget for specific month
  Future<BudgetModel?> getBudget({
    required int userId,
    required int month,
    required int year,
  }) async {
    try {
      final results = await _db.queryWhere(
        AppStrings.tableBudget,
        'userId = ? AND month = ? AND year = ?',
        [userId, month, year],
      );

      if (results.isEmpty) return null;
      return BudgetModel.fromMap(results.first);
    } catch (e) {
      return null;
    }
  }

  // Update spent amount
  Future<bool> updateSpentAmount({
    required int userId,
    required int month,
    required int year,
  }) async {
    try {
      final budget = await getBudget(userId: userId, month: month, year: year);
      if (budget == null) return false;

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      final spentAmount = await _expenseService.getTotalExpenses(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final updatedBudget = budget.copyWith(spentAmount: spentAmount);
      await _db.update(AppStrings.tableBudget, updatedBudget.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if over budget
  Future<bool> isOverBudget({
    required int userId,
    required int month,
    required int year,
  }) async {
    final budget = await getBudget(userId: userId, month: month, year: year);
    if (budget == null) return false;
    return budget.isOverBudget;
  }

  // Get all budgets for user
  Future<List<BudgetModel>> getAllBudgets(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableBudget,
      'userId = ?',
      [userId],
    );
    return results.map((e) => BudgetModel.fromMap(e)).toList();
  }
}
