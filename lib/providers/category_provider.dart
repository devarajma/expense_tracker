import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/services/category_service.dart';
import 'package:expense_tracker/providers/auth_provider.dart';

// Category list providers
final categoryListProvider = FutureProvider.family<List<CategoryModel>, int>((ref, userId) async {
  final service = ref.watch(categoryServiceProvider);
  return await service.getAllCategories(userId);
});

final incomeCategoryListProvider = FutureProvider.family<List<String>, int>((ref, userId) async {
  final service = ref.watch(categoryServiceProvider);
  final categories = await service.getIncomeCategories(userId);
  return categories.map((c) => c.name).toList();
});

final expenseCategoryListProvider = FutureProvider.family<List<String>, int>((ref, userId) async {
  final service = ref.watch(categoryServiceProvider);
  final categories = await service.getExpenseCategories(userId);
  return categories.map((c) => c.name).toList();
});

// Category notifier for CRUD
class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoryService _service;
  final int userId;

  CategoryNotifier(this._service, this.userId) : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _service.getAllCategories(userId);
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addCategory(CategoryModel category) async {
    try {
      await _service.addCategory(category);
      await _loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _service.updateCategory(category);
      await _loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _service.deleteCategory(id);
      await _loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final categoryNotifierProvider = StateNotifierProvider.family<CategoryNotifier, AsyncValue<List<CategoryModel>>, int>(
  (ref, userId) {
    final service = ref.watch(categoryServiceProvider);
    return CategoryNotifier(service, userId);
  },
);
