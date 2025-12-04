import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/services/budget_service.dart';
import 'package:expense_tracker/models/budget_model.dart';
import 'package:expense_tracker/widgets/custom_button.dart';
import 'package:expense_tracker/widgets/custom_text_field.dart';
import 'package:expense_tracker/utils/helpers.dart';
import 'package:flutter/services.dart';

final budgetServiceProvider = Provider((ref) => BudgetService());
final currentBudgetProvider = FutureProvider.family<BudgetModel?, int>((ref, userId) async {
  final service = ref.watch(budgetServiceProvider);
  final now = DateTime.now();
  return await service.getBudget(userId: userId, month: now.month, year: now.year);
});

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _budgetController = TextEditingController();

  Future<void> _setBudget() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    final now = DateTime.now();
    final service = ref.read(budgetServiceProvider);
    final success = await service.setBudget(
      userId: user.id!,
      monthlyBudget: budget,
      month: now.month,
      year: now.year,
    );

    if (mounted) {
      if (success) {
        ref.invalidate(currentBudgetProvider(user.id!));
        _budgetController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update budget')),
        );
      }
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please login'));

          final userId = user.id!;
          final budgetAsync = ref.watch(currentBudgetProvider(userId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Budget Card
                budgetAsync.when(
                  data: (budget) {
                    if (budget == null) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(Icons.account_balance, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No budget set for this month',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Card(
                      elevation: 3,
                      color: budget.isOverBudget
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget for ${Helpers.formatMonthYear(DateTime(budget.year, budget.month))}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: (budget.percentUsed / 100).clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(
                                budget.isOverBudget ? Colors.red : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${budget.percentUsed.toStringAsFixed(1)}% Used'),
                                Text(
                                  '${Helpers.formatCurrency(budget.spentAmount)} / ${Helpers.formatCurrency(budget.monthlyBudget)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (budget.isOverBudget)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Over budget by ${Helpers.formatCurrency(budget.spentAmount - budget.monthlyBudget)}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Text(
                                'Remaining: ${Helpers.formatCurrency(budget.remainingBudget)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),

                const SizedBox(height: 24),

                // Set Budget Card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Monthly Budget',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _budgetController,
                          label: 'Budget Amount',
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          onPressed: _setBudget,
                          text: 'Set Budget',
                          icon: Icons.save,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tips Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Budget Tips',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _TipItem(text: 'Set a realistic budget based on your income'),
                        const _TipItem(text: 'Review your expenses regularly'),
                        const _TipItem(text: 'Adjust your budget as needed'),
                        const _TipItem(text: 'Track unexpected expenses'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
