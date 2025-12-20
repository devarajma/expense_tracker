import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/summary_provider.dart';
import 'package:expense_tracker/widgets/summary_card.dart';
import 'package:expense_tracker/widgets/transaction_list_item.dart';
import 'package:expense_tracker/utils/constants.dart';
import 'package:expense_tracker/screens/income/income_screen.dart';
import 'package:expense_tracker/screens/expense/expense_screen.dart';
import 'package:expense_tracker/screens/profit/profit_screen.dart';
import 'package:expense_tracker/screens/gst/gst_calculator_screen.dart';
import 'package:expense_tracker/screens/inventory/inventory_screen.dart';
import 'package:expense_tracker/screens/budget/budget_screen.dart';
import 'package:expense_tracker/screens/booking/booking_list_screen.dart';
import 'package:expense_tracker/screens/wishlist/wishlist_screen.dart';
import 'package:expense_tracker/providers/booking_provider.dart';
import 'package:expense_tracker/providers/wishlist_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please login'));
          }

          final userId = user.id!;
          final dailySummaryAsync = ref.watch(dailySummaryProvider(userId));
          final recentTransactionsAsync = ref.watch(recentTransactionsProvider(userId));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dailySummaryProvider(userId));
              ref.invalidate(recentTransactionsProvider(userId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message
                    Text(
                      'Welcome, ${user.username}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s your financial overview for today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Summary cards
                    dailySummaryAsync.when(
                      data: (summary) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SummaryCard(
                                    title: 'Income',
                                    amount: summary.totalIncome,
                                    icon: Icons.arrow_downward,
                                    color: AppColors.income,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SummaryCard(
                                    title: 'Expense',
                                    amount: summary.totalExpense,
                                    icon: Icons.arrow_upward,
                                    color: AppColors.expense,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SummaryCard(
                              title: 'Today\'s Profit',
                              amount: summary.profit,
                              icon: Icons.account_balance_wallet,
                              color: summary.profit >= 0
                                  ? AppColors.profit
                                  : AppColors.error,
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Error: $error'),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: [
                        _QuickActionCard(
                          icon: Icons.add_circle,
                          label: 'Add Income',
                          color: AppColors.income,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const IncomeScreen()),
                            );
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.remove_circle,
                          label: 'Add Expense',
                          color: AppColors.expense,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExpenseScreen()),
                            );
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.bar_chart,
                          label: 'Profit',
                          color: AppColors.profit,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProfitScreen()),
                            );
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.calculate,
                          label: 'GST',
                          color: AppColors.secondary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const GSTCalculatorScreen()),
                            );
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.inventory,
                          label: 'Inventory',
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const InventoryScreen()),
                            );
                          },
                        ),
                        _QuickActionCard(
                          icon: Icons.account_balance,
                          label: 'Budget',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BudgetScreen()),
                            );
                          },
                        ),
                        _QuickActionCardWithBadge(
                          icon: Icons.event_note,
                          label: 'Bookings',
                          color: Colors.purple,
                          badgeCount: ref.watch(todayBookingCountProvider),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BookingListScreen()),
                            );
                          },
                        ),
                        _QuickActionCardWithBadge(
                          icon: Icons.shopping_cart,
                          label: 'Wishlist',
                          color: Colors.teal,
                          badgeCount: ref.watch(highPriorityWishlistCountProvider),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WishlistScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const IncomeScreen()),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    recentTransactionsAsync.when(
                      data: (transactions) {
                        if (transactions.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transactions yet',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: transactions
                              .map((transaction) => TransactionListItem(
                                    transaction: transaction,
                                  ))
                              .toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCardWithBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int badgeCount;
  final VoidCallback onTap;

  const _QuickActionCardWithBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 28, color: color),
                  if (badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
