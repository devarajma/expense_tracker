import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/inventory_model.dart';
import 'package:expense_tracker/services/inventory_service.dart';
import 'package:expense_tracker/providers/auth_provider.dart';

final inventoryServiceProvider = Provider((ref) => InventoryService());

class InventoryNotifier extends StateNotifier<AsyncValue<List<InventoryModel>>> {
  final InventoryService _inventoryService;
  final int _userId;

  InventoryNotifier(this._inventoryService, this._userId)
      : super(const AsyncValue.loading()) {
    loadInventory();
  }

  Future<void> loadInventory() async {
    state = const AsyncValue.loading();
    try {
      final items = await _inventoryService.getAllItems(_userId);
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addItem(InventoryModel item) async {
    try {
      final id = await _inventoryService.addItem(item);
      if (id > 0) {
        await loadInventory();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItem(InventoryModel item) async {
    try {
      final result = await _inventoryService.updateItem(item);
      if (result) {
        await loadInventory();
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      final result = await _inventoryService.deleteItem(id);
      if (result) {
        await loadInventory();
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addStock({
    required int itemId,
    required int quantity,
    required String reason,
    DateTime? date,
  }) async {
    try {
      final result = await _inventoryService.addStock(
        itemId: itemId,
        userId: _userId,
        quantity: quantity,
        reason: reason,
        date: date,
      );
      if (result) {
        await loadInventory();
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> useStock({
    required int itemId,
    required int quantity,
    required String reason,
    DateTime? date,
  }) async {
    try {
      final result = await _inventoryService.useStock(
        itemId: itemId,
        userId: _userId,
        quantity: quantity,
        reason: reason,
        date: date,
      );
      if (result) {
        await loadInventory();
      }
      return result;
    } catch (e) {
      return false;
    }
  }
}

final inventoryNotifierProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<InventoryModel>>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  final inventoryService = ref.watch(inventoryServiceProvider);
  
  if (user == null) {
    return InventoryNotifier(inventoryService, 0);
  }
  
  return InventoryNotifier(inventoryService, user.id!);
});

// Low stock items provider
final lowStockItemsProvider = Provider<List<InventoryModel>>((ref) {
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.isLowStock).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Critical stock items provider
final criticalStockItemsProvider = Provider<List<InventoryModel>>((ref) {
  final inventoryAsync = ref.watch(inventoryNotifierProvider);
  return inventoryAsync.when(
    data: (items) => items.where((item) => item.isCritical).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Low stock count provider
final lowStockCountProvider = Provider<int>((ref) {
  final lowStockItems = ref.watch(lowStockItemsProvider);
  return lowStockItems.length;
});
