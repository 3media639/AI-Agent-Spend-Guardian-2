import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_config.dart';

class BudgetNotifier extends StateNotifier<BudgetConfig> {
  BudgetNotifier()
      : super(
          BudgetConfig(
            dailyBudget: 15.0,
            monthlyBudget: 120.0,
            alertAt70: true,
            alertAt90: true,
            isHardLimitEnabled: false,
            pushNotificationsEnabled: true,
            emailAlertsEnabled: true,
            alertEmail: 'alex.developer@example.com',
            updatedAt: DateTime.now(),
          ),
        );

  void updateBudgets({
    required double dailyBudget,
    required double monthlyBudget,
  }) {
    state = state.copyWith(
      dailyBudget: dailyBudget,
      monthlyBudget: monthlyBudget,
      updatedAt: DateTime.now(),
    );
  }

  void toggleHardLimit(bool enabled) {
    state = state.copyWith(
      isHardLimitEnabled: enabled,
      updatedAt: DateTime.now(),
    );
  }

  void toggleAlert70(bool enabled) {
    state = state.copyWith(
      alertAt70: enabled,
      updatedAt: DateTime.now(),
    );
  }

  void toggleAlert90(bool enabled) {
    state = state.copyWith(
      alertAt90: enabled,
      updatedAt: DateTime.now(),
    );
  }

  void updateNotificationSettings({
    bool? pushEnabled,
    bool? emailEnabled,
    String? email,
  }) {
    state = state.copyWith(
      pushNotificationsEnabled: pushEnabled ?? state.pushNotificationsEnabled,
      emailAlertsEnabled: emailEnabled ?? state.emailAlertsEnabled,
      alertEmail: email ?? state.alertEmail,
      updatedAt: DateTime.now(),
    );
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetConfig>((ref) {
  return BudgetNotifier();
});
