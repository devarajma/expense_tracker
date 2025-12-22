import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/utils/constants.dart';

class IncomeService {
  final _db = DatabaseHelper.instance;

  // Add income
  Future<int> addIncome(IncomeModel income) async {
    return await _db.insert(AppStrings.tableIncome, income.toMap());
  }

  // Update income
  Future<bool> updateIncome(IncomeModel income) async {
    final result = await _db.update(AppStrings.tableIncome, income.toMap());
    return result > 0;
  }

  // Delete income
  Future<bool> deleteIncome(int id) async {
    final result = await _db.delete(AppStrings.tableIncome, id);
    return result > 0;
  }

  // Get all income for user
  Future<List<IncomeModel>> getAllIncome(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableIncome,
      'userId = ?',
      [userId],
    );
    return results.map((e) => IncomeModel.fromMap(e)).toList();
  }

  // Get income by date range
  Future<List<IncomeModel>> getIncomeByDateRange({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allIncome = await getAllIncome(userId);
    return allIncome.where((income) {
      return !income.date.isBefore(startDate) &&
          !income.date.isAfter(endDate);
    }).toList();
  }

  // Get income by category
  Future<List<IncomeModel>> getIncomeByCategory({
    required int userId,
    required String category,
  }) async {
    final results = await _db.queryWhere(
      AppStrings.tableIncome,
      'userId = ? AND category = ?',
      [userId, category],
    );
    return results.map((e) => IncomeModel.fromMap(e)).toList();
  }

  // Get total income for period
  Future<double> getTotalIncome({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final incomes = await getIncomeByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
    return incomes.fold<double>(0.0, (sum, income) => sum + income.amount);
  }

  // Get daily total
  Future<double> getDailyTotal(int userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return await getTotalIncome(
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
    return await getTotalIncome(
      userId: userId,
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  // Get monthly total
  Future<double> getMonthlyTotal(int userId, DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    return await getTotalIncome(
      userId: userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }
}
