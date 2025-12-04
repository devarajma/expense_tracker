import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/services/income_service.dart';
import 'package:expense_tracker/providers/summary_provider.dart';

// Income list provider
final incomeListProvider = FutureProvider.family<List<IncomeModel>, int>((ref, userId) async {
  final service = ref.watch(incomeServiceProvider);
  final incomes = await service.getAllIncome(userId);
  incomes.sort((a, b) => b.date.compareTo(a.date));
  return incomes;
});

// Income notifier for CRUD operations
class IncomeNotifier extends StateNotifier<AsyncValue<List<IncomeModel>>> {
  final IncomeService _service;
  final int userId;

  IncomeNotifier(this._service, this.userId) : super(const AsyncValue.loading()) {
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    state = const AsyncValue.loading();
    try {
      final incomes = await _service.getAllIncome(userId);
      incomes.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(incomes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addIncome(IncomeModel income) async {
    try {
      await _service.addIncome(income);
      await _loadIncomes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateIncome(IncomeModel income) async {
    try {
      await _service.updateIncome(income);
      await _loadIncomes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteIncome(int id) async {
    try {
      await _service.deleteIncome(id);
      await _loadIncomes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<IncomeModel>> getIncomeByDateRange(DateTime start, DateTime end) async {
    return await _service.getIncomeByDateRange(
      userId: userId,
      startDate: start,
      endDate: end,
    );
  }
}

final incomeNotifierProvider = StateNotifierProvider.family<IncomeNotifier, AsyncValue<List<IncomeModel>>, int>(
  (ref, userId) {
    final service = ref.watch(incomeServiceProvider);
    return IncomeNotifier(service, userId);
  },
);
