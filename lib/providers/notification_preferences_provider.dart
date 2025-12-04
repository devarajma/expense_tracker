import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  final bool budgetAlerts;
  final bool lowStockAlerts;
  final bool dailySummary;

  NotificationPreferences({
    this.budgetAlerts = true,
    this.lowStockAlerts = true,
    this.dailySummary = false,
  });

  NotificationPreferences copyWith({
    bool? budgetAlerts,
    bool? lowStockAlerts,
    bool? dailySummary,
  }) {
    return NotificationPreferences(
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
      dailySummary: dailySummary ?? this.dailySummary,
    );
  }
}

class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(NotificationPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationPreferences(
      budgetAlerts: prefs.getBool('budget_alerts') ?? true,
      lowStockAlerts: prefs.getBool('low_stock_alerts') ?? true,
      dailySummary: prefs.getBool('daily_summary') ?? false,
    );
  }

  Future<void> setBudgetAlerts(bool enabled) async {
    state = state.copyWith(budgetAlerts: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budget_alerts', enabled);
  }

  Future<void> setLowStockAlerts(bool enabled) async {
    state = state.copyWith(lowStockAlerts: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('low_stock_alerts', enabled);
  }

  Future<void> setDailySummary(bool enabled) async {
    state = state.copyWith(dailySummary: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_summary', enabled);
  }
}

final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});
