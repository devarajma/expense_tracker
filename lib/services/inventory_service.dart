import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/inventory_model.dart';
import 'package:expense_tracker/utils/constants.dart';

class InventoryService {
  final _db = DatabaseHelper.instance;

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

  // Update quantity
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
}
