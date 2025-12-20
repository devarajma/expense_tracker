import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/inventory_history_model.dart';
import 'package:expense_tracker/models/stock_action_reason.dart';
import 'package:expense_tracker/utils/constants.dart';

class InventoryHistoryService {
  final _db = DatabaseHelper.instance;

  // Add history record
  Future<int> addHistory(InventoryHistoryModel history) async {
    return await _db.insert('inventory_history', history.toMap());
  }

  // Get all history for an inventory item
  Future<List<InventoryHistoryModel>> getHistoryForItem({
    required int inventoryId,
  }) async {
    final maps = await _db.queryWhere(
      'inventory_history',
      'inventory_id = ?',
      [inventoryId],
    );
    return maps.map((map) => InventoryHistoryModel.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  // Get history for user (all items)
  Future<List<InventoryHistoryModel>> getHistoryForUser({
    required int userId,
  }) async {
    final maps = await _db.queryWhere(
      'inventory_history',
      'user_id = ?',
      [userId],
    );
    return maps.map((map) => InventoryHistoryModel.fromMap(map)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get history by date range
  Future<List<InventoryHistoryModel>> getHistoryByDateRange({
    required int inventoryId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allHistory = await getHistoryForItem(inventoryId: inventoryId);
    return allHistory.where((history) {
      return history.date.isAfter(startDate) && history.date.isBefore(endDate);
    }).toList();
  }

  // Calculate total added for item
  Future<int> getTotalAdded({required int inventoryId}) async {
    final history = await getHistoryForItem(inventoryId: inventoryId);
    return history
        .where((h) => h.actionType == StockActionType.add)
        .fold<int>(0, (sum, h) => sum + h.quantity);
  }

  // Calculate total used for item
  Future<int> getTotalUsed({required int inventoryId}) async {
    final history = await getHistoryForItem(inventoryId: inventoryId);
    return history
        .where((h) => h.actionType == StockActionType.use)
        .fold<int>(0, (sum, h) => sum + h.quantity);
  }

  // Delete history record
  Future<int> deleteHistory(int id) async {
    return await _db.delete('inventory_history', id);
  }

  // Delete all history for an item (cascade on item delete)
  Future<int> deleteHistoryForItem(int inventoryId) async {
    final db = await _db.database;
    return await db.delete(
      'inventory_history',
      where: 'inventory_id = ?',
      whereArgs: [inventoryId],
    );
  }
}
