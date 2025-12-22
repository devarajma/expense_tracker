import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/inventory_model.dart';
import 'package:expense_tracker/models/inventory_history_model.dart';
import 'package:expense_tracker/models/stock_action_reason.dart';
import 'package:expense_tracker/services/inventory_history_service.dart';
import 'package:expense_tracker/screens/inventory/dialogs/stock_action_dialog.dart';
import 'package:expense_tracker/providers/inventory_provider.dart';
import 'package:expense_tracker/screens/wishlist/add_wishlist_screen.dart';
import 'package:expense_tracker/models/wishlist_model.dart';

final historyServiceProvider = Provider((ref) => InventoryHistoryService());
final itemHistoryProvider = FutureProvider.family<List<InventoryHistoryModel>, int>((ref, inventoryId) async {
  final service = ref.watch(historyServiceProvider);
  return await service.getHistoryForItem(inventoryId: inventoryId);
});

class InventoryDetailsScreen extends ConsumerWidget {
  final InventoryModel item;

  const InventoryDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(itemHistoryProvider(item.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock level card
            _StockLevelCard(item: item),
            
            // Quick actions
            _QuickActionsCard(item: item),

            // Low stock action
            if (item.isCritical) _LowStockCard(item: item),

            // Item details
            _ItemDetailsCard(item: item),

            // History
            _HistorySection(historyAsync: historyAsync),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure? This will delete all history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await ref.read(inventoryNotifierProvider.notifier).deleteItem(item.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Item deleted' : 'Failed to delete'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class _StockLevelCard extends StatelessWidget {
  final InventoryModel item;

  const _StockLevelCard({required this.item});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (item.stockLevel) {
      case StockLevel.safe:
        color = Colors.green;
        break;
      case StockLevel.low:
        color = Colors.orange;
        break;
      case StockLevel.critical:
        color = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Stock', style: TextStyle(fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    item.stockLevel.displayName,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${item.quantity}',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
            ),
            Text(item.unit, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: item.stockPercentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum: ${item.lowStockThreshold} ${item.unit}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final InventoryModel item;

  const _QuickActionsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStockDialog(context, StockActionType.add),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stock'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStockDialog(context, StockActionType.use),
                    icon: const Icon(Icons.remove),
                    label: const Text('Use Stock'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStockDialog(BuildContext context, StockActionType type) {
    showDialog(
      context: context,
      builder: (_) => StockActionDialog(item: item, actionType: type),
    );
  }
}

class _LowStockCard extends ConsumerWidget {
  final InventoryModel item;

  const _LowStockCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alert!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Stock is below minimum level. Consider adding to wishlist for reorder.',
              style: TextStyle(color: Colors.red.shade900),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _addToWishlist(context, ref),
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add to Wishlist'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            ),
          ],
        ),
      ),
    );
  }

  void _addToWishlist(BuildContext context, WidgetRef ref) {
    final suggestedQty = (item.lowStockThreshold * 2) - item.quantity;
    final now = DateTime.now();
    final monthYear = '${now.month}/${now.year}';
    
    final wishlistItem = WishlistModel(
      userId: item.userId,
      itemName: item.name,
      quantity: suggestedQty > 0 ? suggestedQty : item.lowStockThreshold,
      priority: WishlistPriority.high,
      expectedMonth: monthYear,
      notes: 'Low stock reorder for inventory',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddWishlistScreen(wishlistItem: wishlistItem),
      ),
    );
  }
}

class _ItemDetailsCard extends StatelessWidget {
  final InventoryModel item;

  const _ItemDetailsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (item.category != null) _DetailRow('Category', item.category!),
            _DetailRow('Unit', item.unit),
            _DetailRow('Minimum Level', '${item.lowStockThreshold} ${item.unit}'),
            _DetailRow('Last Updated', _formatDate(item.lastUpdated)),
            if (item.notes != null) ...[
              const SizedBox(height: 8),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(item.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _HistorySection extends StatelessWidget {
  final AsyncValue<List<InventoryHistoryModel>> historyAsync;

  const _HistorySection({required this.historyAsync});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No history yet', style: TextStyle(color: Colors.grey)),
                  );
                }
                return Column(
                  children: history.take(5).map((h) => _HistoryTile(history: h)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final InventoryHistoryModel history;

  const _HistoryTile({required this.history});

  @override
  Widget build(BuildContext context) {
    final isAdd = history.actionType == StockActionType.add;
    final color = isAdd ? Colors.green : Colors.orange;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(isAdd ? Icons.add : Icons.remove, color: color, size: 20),
      ),
      title: Text(history.reason),
      subtitle: Text(history.formattedDate),
      trailing: Text(
        '${isAdd ? '+' : '-'}${history.quantity}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
