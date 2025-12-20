import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/wishlist_model.dart';
import 'package:expense_tracker/providers/wishlist_provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';

class AddWishlistScreen extends ConsumerStatefulWidget {
  final WishlistModel? wishlistItem;

  const AddWishlistScreen({super.key, this.wishlistItem});

  @override
  ConsumerState<AddWishlistScreen> createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends ConsumerState<AddWishlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  WishlistPriority _selectedPriority = WishlistPriority.medium;
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.wishlistItem != null) {
      _itemNameController.text = widget.wishlistItem!.itemName;
      _quantityController.text = widget.wishlistItem!.quantity.toString();
      _notesController.text = widget.wishlistItem!.notes ?? '';
      _selectedPriority = widget.wishlistItem!.priority;
      
      final parts = widget.wishlistItem!.expectedMonth.split('-');
      _selectedMonth = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    } else {
      _quantityController.text = '1';
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wishlistItem == null ? 'Add to Wishlist' : 'Edit Wishlist Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _itemNameController,
              label: 'Item Name',
              prefixIcon: Icons.shopping_bag,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _quantityController,
              label: 'Quantity',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (int.tryParse(value) == null || int.parse(value) < 1) {
                  return 'Please enter a valid quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              prefixIcon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WishlistPriority>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Select Priority',
                prefixIcon: const Icon(Icons.priority_high),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              items: WishlistPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      _PriorityIndicator(priority: priority),
                      const SizedBox(width: 8),
                      Text(priority.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Expected Purchase Month',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectMonth,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Month',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_formatMonth(_selectedMonth)),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: _isLoading ? null : _saveWishlistItem,
              text: widget.wishlistItem == null ? 'Add to Wishlist' : 'Update Item',
              icon: Icons.save,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  String _formatMonth(DateTime date) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> _saveWishlistItem() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    final expectedMonth = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

    final wishlistItem = WishlistModel(
      id: widget.wishlistItem?.id,
      userId: user.id!,
      itemName: _itemNameController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      priority: _selectedPriority,
      expectedMonth: expectedMonth,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.wishlistItem?.createdAt,
    );

    final success = widget.wishlistItem == null
        ? await ref.read(wishlistNotifierProvider.notifier).addWishlistItem(wishlistItem)
        : await ref.read(wishlistNotifierProvider.notifier).updateWishlistItem(wishlistItem);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.wishlistItem == null
                  ? 'Item added to wishlist'
                  : 'Wishlist item updated',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save wishlist item')),
        );
      }
    }
  }
}

class _PriorityIndicator extends StatelessWidget {
  final WishlistPriority priority;

  const _PriorityIndicator({required this.priority});

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
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
