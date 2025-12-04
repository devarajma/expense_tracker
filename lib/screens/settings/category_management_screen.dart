import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/category_provider.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen>
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

  void _showAddCategoryDialog(String type, [CategoryModel? category]) {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        userId: user.id!,
        type: type,
        category: category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income Categories'),
            Tab(text: 'Expense Categories'),
          ],
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please login'));

          final userId = user.id!;

          return TabBarView(
            controller: _tabController,
            children: [
              _CategoryList(userId: userId, type: 'income', onAdd: () => _showAddCategoryDialog('income')),
              _CategoryList(userId: userId, type: 'expense', onAdd: () => _showAddCategoryDialog('expense')),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final int userId;
  final String type;
  final VoidCallback onAdd;

  const _CategoryList({
    required this.userId,
    required this.type,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryNotifierProvider(userId));

    return categoriesAsync.when(
      data: (categories) {
        final filteredCategories = categories.where((c) => c.type == type).toList();

        return Column(
          children: [
            Expanded(
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No ${type} categories yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return ListTile(
                          leading: const Icon(Icons.label),
                          title: Text(category.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Category'),
                                  content: const Text(
                                      'Are you sure you want to delete this category?'),
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

                              if (confirm == true && context.mounted) {
                                await ref
                                    .read(categoryNotifierProvider(userId).notifier)
                                    .deleteCategory(category.id!);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                onPressed: onAdd,
                text: 'Add ${type == 'income' ? 'Income' : 'Expense'} Category',
                icon: Icons.add,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _CategoryDialog extends ConsumerStatefulWidget {
  final int userId;
  final String type;
  final CategoryModel? category;

  const _CategoryDialog({
    required this.userId,
    required this.type,
    this.category,
  });

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final category = CategoryModel(
      id: widget.category?.id,
      name: _nameController.text,
      type: widget.type,
      userId: widget.userId,
    );

    final success = await ref
        .read(categoryNotifierProvider(widget.userId).notifier)
        .addCategory(category);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save category')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.type == 'income' ? 'Income' : 'Expense'} Category'),
      content: Form(
        key: _formKey,
        child: CustomTextField(
          controller: _nameController,
          label: 'Category Name',
          prefixIcon: Icons.label,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter category name';
            }
            return null;
          },
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
