import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/inventory_model.dart';
import 'package:expense_tracker/models/stock_action_reason.dart';
import 'package:expense_tracker/providers/inventory_provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/screens/inventory/dialogs/stock_action_dialog.dart';
import 'package:expense_tracker/screens/inventory/inventory_details_screen.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:flutter/services.dart';

class EnhancedInventoryScreen extends ConsumerStatefulWidget {
  const EnhancedInventoryScreen({super.key});

  @override
  ConsumerState<EnhancedInventoryScreen> createState() => _EnhancedInventoryScreenState();
}

class _EnhancedInventoryScreenState extends ConsumerState<EnhancedInventoryScreen> {
  String _sortBy = 'name'; // name, stock_level, quantity

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final user = ref.watch(authNotifierProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'name', child: Text('Name ${_sortBy == 'name' ? '✓' : ''}')),
              PopupMenuItem(value: 'stock_level', child: Text('Stock Level ${_sortBy == 'stock_level' ? '✓' : ''}')),
              PopupMenuItem(value: 'quantity', child: Text('Quantity ${_sortBy == 'quantity' ? '✓' : ''}')),
            ],
          ),
        ],
      ),
      body: inventoryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No inventory items', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Item'),
                  ),
                ],
              ),
            );
          }

          // Sort items
          final sortedItems = _sortItems(items);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return _EnhancedInventoryCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  List<InventoryModel> _sortItems(List<InventoryModel> items) {
    final sorted = List<InventoryModel>.from(items);
    switch (_sortBy) {
      case 'stock_level':
        sorted.sort((a, b) => a.stockLevel.index.compareTo(b.stockLevel.index));
        break;
      case 'quantity':
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'name':
      default:
        sorted.sort((a, b) => a.name.compareTo(b.name));
    }
    return sorted;
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddInventoryDialog(),
    );
  }
}

class _EnhancedInventoryCard extends ConsumerWidget {
  final InventoryModel item;

  const _EnhancedInventoryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockColor = _getStockColor(item.stockLevel);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InventoryDetailsScreen(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StockLevelBadge(level: item.stockLevel),
                ],
              ),
              if (item.category != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.category!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),

              // Stock progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stock: ${item.quantity} ${item.unit}'),
                      Text(
                        'Min: ${item.lowStockThreshold}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: item.stockPercentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showStockAction(context, item, StockActionType.add),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Stock'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showStockAction(context, item, StockActionType.use),
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text('Use Stock'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor(StockLevel level) {
    switch (level) {
      case StockLevel.safe:
        return Colors.green;
      case StockLevel.low:
        return Colors.orange;
      case StockLevel.critical:
        return Colors.red;
    }
  }

  void _showStockAction(BuildContext context, InventoryModel item, StockActionType type) {
    showDialog(
      context: context,
      builder: (_) => StockActionDialog(item: item, actionType: type),
    );
  }
}

class _StockLevelBadge extends StatelessWidget {
  final StockLevel level;

  const _StockLevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (level) {
      case StockLevel.safe:
        color =Colors.green;
        icon = Icons.check_circle;
        break;
      case StockLevel.low:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case StockLevel.critical:
        color = Colors.red;
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            level.displayName,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AddInventoryDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends ConsumerState<_AddInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _minController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Inventory Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Item Name',
                prefixIcon: Icons.inventory,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _categoryController,
                label: 'Category (Optional)',
                prefixIcon: Icons.category,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextField(
                      controller: _unitController,
                      label: 'Unit',
                      prefixIcon: Icons.straighten,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _minController,
                label: 'Minimum Stock Level',
                prefixIcon: Icons.warning,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                prefixIcon: Icons.note,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    final item = InventoryModel(
      userId: user.id!,
      name: _nameController.text,
      category: _categoryController.text.isEmpty ? null : _categoryController.text,
      quantity: int.parse(_quantityController.text),
      lowStockThreshold: int.parse(_minController.text),
      unit: _unitController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final success = await ref.read(inventoryNotifierProvider.notifier).addItem(item);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add item'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
