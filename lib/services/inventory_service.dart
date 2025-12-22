import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/inventory_model.dart';
import 'package:expense_tracker/models/inventory_history_model.dart';
import 'package:expense_tracker/models/stock_action_reason.dart';
import 'package:expense_tracker/services/inventory_history_service.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/utils/constants.dart';

class InventoryService {
  final _db = DatabaseHelper.instance;
  final _historyService = InventoryHistoryService();
  final _notificationService = NotificationService.instance;

  // Add inventory item
  Future<int> addItem(InventoryModel item) async {
    return await _db.insert(AppStrings.tableInventory, item.toMap());
  }

  // Update inventory item
  Future<bool> updateItem(InventoryModel item) async {
    final result = await _db.update(AppStrings.tableInventory, item.toMap());
    return result > 0;
  }

  // Delete inventory item
  Future<bool> deleteItem(int id) async {
    // Delete history first
    await _historyService.deleteHistoryForItem(id);
    final result = await _db.delete(AppStrings.tableInventory, id);
    return result > 0;
  }

  // Get all inventory items for user
  Future<List<InventoryModel>> getAllItems(int userId) async {
    final results = await _db.queryWhere(
      AppStrings.tableInventory,
      'userId = ?',
      [userId],
    );
    return results.map((e) => InventoryModel.fromMap(e)).toList();
  }

  // Get low stock items
  Future<List<InventoryModel>> getLowStockItems(int userId) async {
    final allItems = await getAllItems(userId);
    return allItems.where((item) => item.isLowStock).toList();
  }

  // Get critical stock items (below minimum)
  Future<List<InventoryModel>> getCriticalStockItems(int userId) async {
    final allItems = await getAllItems(userId);
    return allItems.where((item) => item.isCritical).toList();
  }

  // ADD STOCK - New method
  Future<bool> addStock({
    required int itemId,
    required int userId,
    required int quantity,
    required String reason,
    DateTime? date,
  }) async {
    try {
      // Get current item
      final items = await _db.queryWhere(
        AppStrings.tableInventory,
        'id = ?',
        [itemId],
      );
      
      if (items.isEmpty) return false;
      final item = InventoryModel.fromMap(items.first);

      // Update quantity
      final newQuantity = item.quantity + quantity;
      final db = await _db.database;
      await db.update(
        AppStrings.tableInventory,
        {
          'quantity': newQuantity,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [itemId],
      );

      // Add history record
      final history = InventoryHistoryModel(
        inventoryId: itemId,
        userId: userId,
        actionType: StockActionType.add,
        quantity: quantity,
        reason: reason,
        date: date,
      );
      await _historyService.addHistory(history);

      return true;
    } catch (e) {
      return false;
    }
  }

  // USE STOCK - New method
  Future<bool> useStock({
    required int itemId,
    required int userId,
    required int quantity,
    required String reason,
    DateTime? date,
  }) async {
    try {
      // Get current item
      final items = await _db.queryWhere(
        AppStrings.tableInventory,
        'id = ?',
        [itemId],
      );
      
      if (items.isEmpty) return false;
      final item = InventoryModel.fromMap(items.first);

      // Check if enough stock
      if (item.quantity < quantity) {
        return false;
      }

      // Update quantity
      final newQuantity = item.quantity - quantity;
      final db = await _db.database;
      await db.update(
        AppStrings.tableInventory,
        {
          'quantity': newQuantity,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [itemId],
      );

      // Add history record
      final history = InventoryHistoryModel(
        inventoryId: itemId,
        userId: userId,
        actionType: StockActionType.use,
        quantity: quantity,
        reason: reason,
        date: date,
      );
      await _historyService.addHistory(history);

      // Check if now low stock and send notification
      if (newQuantity < item.lowStockThreshold) {
        await _notificationService.showLowStockAlert(
          title: 'Low Stock Alert',
          body: '${item.name} is running low: $newQuantity ${item.unit} remaining (minimum: ${item.lowStockThreshold})',
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update quantity (deprecated - use addStock/useStock instead)
  @Deprecated('Use addStock() or useStock() instead')
  Future<bool> updateQuantity({
    required int itemId,
    required int newQuantity,
  }) async {
    try {
      final db = await _db.database;
      final result = await db.update(
        AppStrings.tableInventory,
        {
          'quantity': newQuantity,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [itemId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Check if any items are low on stock
  Future<bool> hasLowStockAlert(int userId) async {
    final lowStockItems = await getLowStockItems(userId);
    return lowStockItems.isNotEmpty;
  }

  // Get item by ID
  Future<InventoryModel?> getItemById(int itemId) async {
    final items = await _db.queryWhere(
      AppStrings.tableInventory,
      'id = ?',
      [itemId],
    );
    if (items.isEmpty) return null;
    return InventoryModel.fromMap(items.first);
  }

  // Sort items by stock level
  List<InventoryModel> sortByStockLevel(List<InventoryModel> items) {
    return items..sort((a, b) => a.stockLevel.index.compareTo(b.stockLevel.index));
  }
}
