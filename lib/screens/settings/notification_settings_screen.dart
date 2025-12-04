import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/providers/notification_preferences_provider.dart';
import 'package:expense_tracker/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Manage your notification preferences',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.account_balance_wallet),
            title: const Text('Budget Alerts'),
            subtitle: const Text('Get notified when you exceed your budget'),
            value: preferences.budgetAlerts,
            onChanged: (value) {
              ref.read(notificationPreferencesProvider.notifier).setBudgetAlerts(value);
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget alerts enabled')),
                );
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.inventory),
            title: const Text('Low Stock Alerts'),
            subtitle: const Text('Get notified when inventory is running low'),
            value: preferences.lowStockAlerts,
            onChanged: (value) {
              ref.read(notificationPreferencesProvider.notifier).setLowStockAlerts(value);
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Low stock alerts enabled')),
                );
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.summarize),
            title: const Text('Daily Summary'),
            subtitle: const Text('Get daily summary of income and expenses'),
            value: preferences.dailySummary,
            onChanged: (value) {
              ref.read(notificationPreferencesProvider.notifier).setDailySummary(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value
                      ? 'Daily summary notifications enabled'
                      : 'Daily summary notifications disabled'),
                ),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About Notifications',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Budget alerts notify you when expenses exceed your monthly budget',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Low stock alerts help you track inventory levels',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Daily summaries provide an overview of your financial activity',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final notificationService = NotificationService.instance;
                await notificationService.showBudgetAlert(
                  title: 'Test Notification',
                  body: 'This is a test notification from Expense Tracker',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification sent!')),
                  );
                }
              },
              icon: const Icon(Icons.notification_add),
              label: const Text('Send Test Notification'),
            ),
          ),
        ],
      ),
    );
  }
}
