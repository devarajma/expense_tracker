import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/stock_action_reason.dart';
import 'package:expense_tracker/models/inventory_model.dart';
import 'package:expense_tracker/providers/inventory_provider.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:expense_tracker/widgets/custom_button.dart';

class StockActionDialog extends ConsumerStatefulWidget {
  final InventoryModel item;
  final StockActionType actionType;

  const StockActionDialog({
    super.key,
    required this.item,
    required this.actionType,
  });

  @override
  ConsumerState<StockActionDialog> createState() => _StockActionDialogState();
}

class _StockActionDialogState extends ConsumerState<StockActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String? _selectedReason;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default reason
    if (widget.actionType == StockActionType.add) {
      _selectedReason = AddStockReason.purchased.displayName;
    } else {
      _selectedReason = UseStockReason.order.displayName;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdd = widget.actionType == StockActionType.add;
    final title = isAdd ? 'Add Stock' : 'Use Stock';
    final icon = isAdd ? Icons.add_circle : Icons.remove_circle;
    final color = isAdd ? Colors.green : Colors.orange;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.item.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current stock info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Stock:'),
                    Text(
                      '${widget.item.quantity} ${widget.item.unit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quantity input
              CustomTextField(
                controller: _quantityController,
                label: 'Quantity',
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  if (!isAdd && qty > widget.item.quantity) {
                    return 'Insufficient stock (only ${widget.item.quantity} available)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason dropdown
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                items: _getReasonOptions(),
                onChanged: (value) {
                  setState(() => _selectedReason = value);
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),

              // Action  buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: _isLoading ? null : _submitAction,
                      text: isAdd ? 'Add' : 'Use',
                      icon: icon,
                      isLoading: _isLoading,
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

  List<DropdownMenuItem<String>> _getReasonOptions() {
    if (widget.actionType == StockActionType.add) {
      return AddStockReason.values
          .map((r) => DropdownMenuItem(
                value: r.displayName,
                child: Text(r.displayName),
              ))
          .toList();
    } else {
      return UseStockReason.values
          .map((r) => DropdownMenuItem(
                value: r.displayName,
                child: Text(r.displayName),
              ))
          .toList();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitAction() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    final quantity = int.parse(_quantityController.text);
    final bool success;

    if (widget.actionType == StockActionType.add) {
      success = await ref.read(inventoryNotifierProvider.notifier).addStock(
            itemId: widget.item.id!,
            quantity: quantity,
            reason: _selectedReason!,
            date: _selectedDate,
          );
    } else {
      success = await ref.read(inventoryNotifierProvider.notifier).useStock(
            itemId: widget.item.id!,
            quantity: quantity,
            reason: _selectedReason!,
            date: _selectedDate,
          );
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.actionType == StockActionType.add
                  ? 'Stock added successfully'
                  : 'Stock used successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update stock'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
