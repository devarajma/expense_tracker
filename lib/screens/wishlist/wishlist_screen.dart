import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/wishlist_provider.dart';
import 'package:expense_tracker/models/wishlist_model.dart';
import 'package:expense_tracker/screens/wishlist/add_wishlist_screen.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = ref.watch(activeWishlistCountProvider);
    final highPriorityCount = ref.watch(highPriorityWishlistCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          if (highPriorityCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('$highPriorityCount High Priority'),
                backgroundColor: Colors.red[100],
                avatar: const Icon(Icons.priority_high, size: 18, color: Colors.red),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Active ($activeCount)',
              icon: const Icon(Icons.list),
            ),
            const Tab(
              text: 'Purchased',
              icon: Icon(Icons.check_circle_outline),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveWishlistTab(),
          _PurchasedWishlistTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addWishlistItem(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _addWishlistItem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddWishlistScreen()),
    );
  }
}

class _ActiveWishlistTab extends ConsumerWidget {
  const _ActiveWishlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedItems = ref.watch(wishlistGroupedByMonthProvider);

    if (groupedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No items in wishlist',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add items you plan to purchase',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final sortedMonths = groupedItems.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final items = groupedItems[month]!;
        
        return _MonthSection(
          month: month,
          items: items,
        );
      },
    );
  }
}

class _MonthSection extends ConsumerWidget {
  final String month;
  final List<WishlistModel> items;

  const _MonthSection({
    required this.month,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Format month display
    final formattedMonth = items.first.formattedMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                formattedMonth,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${items.length}'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        ...items.map((item) => _WishlistItemCard(item: item)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _WishlistItemCard extends ConsumerWidget {
  final WishlistModel item;

  const _WishlistItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: item.isPurchased,
              onChanged: (value) async {
                if (value == true) {
                  await ref.read(wishlistNotifierProvider.notifier).markAsPurchased(item.id!);
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      _PriorityBadge(priority: item.priority),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editItem(context, item);
                } else if (value == 'delete') {
                  _deleteItem(context, ref, item.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editItem(BuildContext context, WishlistModel item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddWishlistScreen(wishlistItem: item),
      ),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(wishlistNotifierProvider.notifier).deleteWishlistItem(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Item deleted' : 'Failed to delete item'),
          ),
        );
      }
    }
  }
}

class _PurchasedWishlistTab extends ConsumerWidget {
  const _PurchasedWishlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasedItems = ref.watch(purchasedWishlistItemsProvider);

    if (purchasedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No purchased items yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchasedItems.length,
      itemBuilder: (context, index) {
        final item = purchasedItems[index];
        return _PurchasedItemCard(item: item);
      },
    );
  }
}

class _PurchasedItemCard extends ConsumerWidget {
  final WishlistModel item;

  const _PurchasedItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Purchased: ${item.purchasedDate != null ? _formatDate(item.purchasedDate!) : 'Unknown'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.orange),
              tooltip: 'Mark as not purchased',
              onPressed: () async {
                await ref.read(wishlistNotifierProvider.notifier).markAsNotPurchased(item.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PriorityBadge extends StatelessWidget {
  final WishlistPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case WishlistPriority.high:
        color = Colors.red;
        break;
      case WishlistPriority.medium:
        color = Colors.orange;
        break;
      case WishlistPriority.low:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
