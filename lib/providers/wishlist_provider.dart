import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/wishlist_model.dart';
import 'package:expense_tracker/services/wishlist_service.dart';
import 'package:expense_tracker/providers/auth_provider.dart';

final wishlistServiceProvider = Provider((ref) => WishlistService());

// Wishlist state notifier
class WishlistNotifier extends StateNotifier<AsyncValue<List<WishlistModel>>> {
  final WishlistService _wishlistService;
  final int _userId;

  WishlistNotifier(this._wishlistService, this._userId)
      : super(const AsyncValue.loading()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    state = const AsyncValue.loading();
    try {
      final items = await _wishlistService.getWishlistItems(userId: _userId);
      state = AsyncValue.data(items);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addWishlistItem(WishlistModel item) async {
    try {
      final id = await _wishlistService.addWishlistItem(item);
      if (id > 0) {
        await loadWishlist();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWishlistItem(WishlistModel item) async {
    try {
      final result = await _wishlistService.updateWishlistItem(item);
      if (result > 0) {
        await loadWishlist();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteWishlistItem(int id) async {
    try {
      final result = await _wishlistService.deleteWishlistItem(id);
      if (result > 0) {
        await loadWishlist();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAsPurchased(int id) async {
    try {
      final result = await _wishlistService.markAsPurchased(id);
      if (result > 0) {
        await loadWishlist();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAsNotPurchased(int id) async {
    try {
      final result = await _wishlistService.markAsNotPurchased(id);
      if (result > 0) {
        await loadWishlist();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final wishlistNotifierProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<WishlistModel>>>((ref) {
  final user = ref.watch(authNotifierProvider).value;
  final wishlistService = ref.watch(wishlistServiceProvider);
  
  if (user == null) {
    return WishlistNotifier(wishlistService, 0);
  }
  
  return WishlistNotifier(wishlistService, user.id!);
});

// Filter providers
final activeWishlistItemsProvider = Provider<List<WishlistModel>>((ref) {
  final wishlistAsync = ref.watch(wishlistNotifierProvider);
  return wishlistAsync.when(
    data: (items) => items.where((item) => !item.isPurchased).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final purchasedWishlistItemsProvider = Provider<List<WishlistModel>>((ref) {
  final wishlistAsync = ref.watch(wishlistNotifierProvider);
  return wishlistAsync.when(
    data: (items) => items.where((item) => item.isPurchased).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final wishlistGroupedByMonthProvider =
    Provider<Map<String, List<WishlistModel>>>((ref) {
  final activeItems = ref.watch(activeWishlistItemsProvider);
  final Map<String, List<WishlistModel>> grouped = {};
  
  for (var item in activeItems) {
    if (!grouped.containsKey(item.expectedMonth)) {
      grouped[item.expectedMonth] = [];
    }
    grouped[item.expectedMonth]!.add(item);
  }
  
  return grouped;
});

final activeWishlistCountProvider = Provider<int>((ref) {
  final activeItems = ref.watch(activeWishlistItemsProvider);
  return activeItems.length;
});

final highPriorityWishlistCountProvider = Provider<int>((ref) {
  final activeItems = ref.watch(activeWishlistItemsProvider);
  return activeItems.where((item) => item.priority == WishlistPriority.high).length;
});
