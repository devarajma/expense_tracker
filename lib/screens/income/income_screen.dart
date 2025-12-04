import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/income_provider.dart';
import 'package:expense_tracker/providers/category_provider.dart';
import 'package:expense_tracker/models/income_model.dart';
import 'package:expense_tracker/widgets/transaction_list_item.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:flutter/services.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  void _showAddIncomeDialog([IncomeModel? income]) {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final categoriesAsync = ref.read(incomeCategoryListProvider(user.id!));

    categoriesAsync.when(
      data: (categories) {
        showDialog(
          context: context,
          builder: (context) => _IncomeDialog(
            userId: user.id!,
            income: income,
            categories: categories,
          ),
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Management'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please login'));

          final userId = user.id!;
          final incomesAsync = ref.watch(incomeNotifierProvider(userId));

          return incomesAsync.when(
            data: (incomes) {
              if (incomes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 100, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No income entries yet',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddIncomeDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Income'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  return TransactionListItem(
                    transaction: income,
                    onTap: () => _showAddIncomeDialog(income),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Income'),
                          content: const Text('Are you sure you want to delete this income entry?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && mounted) {
                        await ref
                            .read(incomeNotifierProvider(userId).notifier)
                            .deleteIncome(income.id!);
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _IncomeDialog extends ConsumerStatefulWidget {
  final int userId;
  final IncomeModel? income;
  final List<String> categories;

  const _IncomeDialog({
    required this.userId,
    this.income,
    required this.categories,
  });

  @override
  ConsumerState<_IncomeDialog> createState() => _IncomeDialogState();
}

class _IncomeDialogState extends ConsumerState<_IncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.income?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.income?.notes ?? '',
    );
    _selectedCategory = widget.income?.category ?? widget.categories.first;
    _selectedDate = widget.income?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final income = IncomeModel(
      id: widget.income?.id,
      userId: widget.userId,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      notes: _notesController.text,
      date: _selectedDate,
    );

    final success = widget.income == null
        ? await ref.read(incomeNotifierProvider(widget.userId).notifier).addIncome(income)
        : await ref.read(incomeNotifierProvider(widget.userId).notifier).updateIncome(income);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save income')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                label: 'Notes',
                prefixIcon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
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
        CustomButton(
          onPressed: _handleSave,
          text: 'Save',
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
