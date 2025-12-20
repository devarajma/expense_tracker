import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/wishlist_model.dart';
import 'package:expense_tracker/utils/constants.dart';

class WishlistService {
  final _db = DatabaseHelper.instance;

  // Add new wishlist item
  Future<int> addWishlistItem(WishlistModel item) async {
    return await _db.insert(AppStrings.tableWishlist, item.toMap());
  }

  // Get all wishlist items for a user
  Future<List<WishlistModel>> getWishlistItems({required int userId}) async {
    final maps = await _db.queryWhere(
      AppStrings.tableWishlist,
      'user_id = ?',
      [userId],
    );
    return maps.map((map) => WishlistModel.fromMap(map)).toList()
      ..sort((a, b) => a.expectedMonth.compareTo(b.expectedMonth));
  }

  // Get active (not purchased) wishlist items
  Future<List<WishlistModel>> getActiveItems({required int userId}) async {
    final maps = await _db.queryWhere(
      AppStrings.tableWishlist,
      'user_id = ? AND is_purchased = 0',
      [userId],
    );
    return maps.map((map) => WishlistModel.fromMap(map)).toList()
      ..sort((a, b) => a.expectedMonth.compareTo(b.expectedMonth));
  }

  // Get purchased wishlist items
  Future<List<WishlistModel>> getPurchasedItems({required int userId}) async {
    final maps = await _db.queryWhere(
      AppStrings.tableWishlist,
      'user_id = ? AND is_purchased = 1',
      [userId],
    );
    return maps.map((map) => WishlistModel.fromMap(map)).toList()
      ..sort((a, b) {
        if (a.purchasedDate == null && b.purchasedDate == null) return 0;
        if (a.purchasedDate == null) return 1;
        if (b.purchasedDate == null) return -1;
        return b.purchasedDate!.compareTo(a.purchasedDate!);
      });
  }

  // Get items by month
  Future<List<WishlistModel>> getItemsByMonth({
    required int userId,
    required String month, // Format: YYYY-MM
  }) async {
    final maps = await _db.queryWhere(
      AppStrings.tableWishlist,
      'user_id = ? AND expected_month = ? AND is_purchased = 0',
      [userId, month],
    );
    return maps.map((map) => WishlistModel.fromMap(map)).toList();
  }

  // Get items grouped by month
  Future<Map<String, List<WishlistModel>>> getItemsGroupedByMonth({
    required int userId,
  }) async {
    final items = await getActiveItems(userId: userId);
    final Map<String, List<WishlistModel>> grouped = {};
    
    for (var item in items) {
      if (!grouped.containsKey(item.expectedMonth)) {
        grouped[item.expectedMonth] = [];
      }
      grouped[item.expectedMonth]!.add(item);
    }
    
    return grouped;
  }

  // Update wishlist item
  Future<int> updateWishlistItem(WishlistModel item) async {
    return await _db.update(AppStrings.tableWishlist, item.toMap());
  }

  // Delete wishlist item
  Future<int> deleteWishlistItem(int id) async {
    return await _db.delete(AppStrings.tableWishlist, id);
  }

  // Mark item as purchased
  Future<int> markAsPurchased(int id) async {
    final items = await _db.queryWhere(
      AppStrings.tableWishlist,
      'id = ?',
      [id],
    );
    
    if (items.isNotEmpty) {
      final item = WishlistModel.fromMap(items.first);
      return await updateWishlistItem(
        item.copyWith(
          isPurchased: true,
          purchasedDate: DateTime.now(),
        ),
      );
    }
    
    return 0;
  }

  // Mark item as not purchased
  Future<int> markAsNotPurchased(int id) async {
    final items = await _db.queryWhere(
      AppStrings.tableWishlist,
      'id = ?',
      [id],
    );
    
    if (items.isNotEmpty) {
      final item = WishlistModel.fromMap(items.first);
      return await updateWishlistItem(
        item.copyWith(
          isPurchased: false,
          purchasedDate: null,
        ),
      );
    }
    
    return 0;
  }

  // Get active item count
  Future<int> getActiveItemCount({required int userId}) async {
    final items = await getActiveItems(userId: userId);
    return items.length;
  }

  // Get high priority item count
  Future<int> getHighPriorityCount({required int userId}) async {
    final items = await getActiveItems(userId: userId);
    return items.where((item) => item.priority == WishlistPriority.high).length;
  }
}
