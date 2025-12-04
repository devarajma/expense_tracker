import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/utils/constants.dart';

class CategoryService {
  final _db = DatabaseHelper.instance;

  // Add category
  Future<int> addCategory(CategoryModel category) async {
    return await _db.insert(AppStrings.tableCategory, category.toMap());
  }

  // Update category
  Future<bool> updateCategory(CategoryModel category) async {
    final result = await _db.update(AppStrings.tableCategory, category.toMap());
    return result > 0;
  }

  // Delete category
  Future<bool> deleteCategory(int id) async {
    final result = await _db.delete(AppStrings.tableCategory, id);
    return result > 0;
  }

  // Get all categories for user
  Future<List<CategoryModel>> getAllCategories(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableCategory,
      'userId = ?',
      [userId],
    );
    return results.map((e) => CategoryModel.fromMap(e)).toList();
  }

  // Get income categories
  Future<List<CategoryModel>> getIncomeCategories(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableCategory,
      'userId = ? AND type = ?',
      [userId, 'income'],
    );
    return results.map((e) => CategoryModel.fromMap(e)).toList();
  }

  // Get expense categories
  Future<List<CategoryModel>> getExpenseCategories(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableCategory,
      'userId = ? AND type = ?',
      [userId, 'expense'],
    );
    return results.map((e) => CategoryModel.fromMap(e)).toList();
  }

  // Initialize default categories for new user
  Future<void> initializeDefaultCategories(int userId) async {
    // Add default income categories
    for (final name in DefaultCategories.incomeCategories) {
      await addCategory(CategoryModel(
        name: name,
        type: 'income',
        userId: userId,
      ));
    }

    // Add default expense categories
    for (final name in DefaultCategories.expenseCategories) {
      await addCategory(CategoryModel(
        name: name,
        type: 'expense',
        userId: userId,
      ));
    }
  }
}
