import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:expense_tracker/providers/summary_provider.dart';

// Expense list provider
final expenseListProvider = FutureProvider.family<List<ExpenseModel>, int>((ref, userId) async {
  final service = ref.watch(expenseServiceProvider);
  final expenses = await service.getAllExpenses(userId);
  expenses.sort((a, b) => b.date.compareTo(a.date));
  return expenses;
});

// Expense notifier for CRUD operations
class ExpenseNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseService _service;
  final int userId;

  ExpenseNotifier(this._service, this.userId) : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _service.getAllExpenses(userId);
      expenses.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      await _service.addExpense(expense);
      await _loadExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      await _service.updateExpense(expense);
      await _loadExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _service.deleteExpense(id);
      await _loadExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    return await _service.getExpensesByDateRange(
      userId: userId,
      startDate: start,
      endDate: end,
    );
  }
}

final expenseNotifierProvider = StateNotifierProvider.family<ExpenseNotifier, AsyncValue<List<ExpenseModel>>, int>(
  (ref, userId) {
    final service = ref.watch(expenseServiceProvider);
    return ExpenseNotifier(service, userId);
  },
);
