import 'package:flutter_test/flutter_test.dart';
import 'package:spendguard/core/constants/app_constants.dart';
import 'package:spendguard/features/budget/models/budget_config.dart';
import 'package:spendguard/features/dashboard/models/spend_data.dart';

void main() {
  group('BudgetConfig Tests', () {
    test('Default budget limits initialize accurately', () {
      final config = BudgetConfig(updatedAt: DateTime.now());
      expect(config.dailyBudget, equals(AppConstants.defaultDailyBudget));
      expect(config.monthlyBudget, equals(AppConstants.defaultMonthlyBudget));
      expect(config.alertAt70, isTrue);
      expect(config.alertAt90, isTrue);
      expect(config.isHardLimitEnabled, isFalse);
    });

    test('Budget progress calculation detects limit breaches', () {
      final summary = DashboardSpendSummary(
        spentToday: 16.50,
        spentThisMonth: 130.00,
        dailyBudget: 15.00,
        monthlyBudget: 120.00,
        recentDailySpend: [],
        providerBreakdown: [],
        topModels: [],
        isFrozen: false,
        lastRefreshed: DateTime.now(),
      );

      expect(summary.isDailyBudgetExceeded, isTrue);
      expect(summary.isMonthlyBudgetExceeded, isTrue);
      expect(summary.monthlyBudgetProgress, greaterThanOrEqualTo(1.0));
    });

    test('Budget progress handles zero budget without division by zero', () {
      final summary = DashboardSpendSummary(
        spentToday: 5.0,
        spentThisMonth: 20.0,
        dailyBudget: 0.0,
        monthlyBudget: 0.0,
        recentDailySpend: [],
        providerBreakdown: [],
        topModels: [],
        isFrozen: false,
        lastRefreshed: DateTime.now(),
      );

      expect(summary.monthlyBudgetProgress, equals(0.0));
      expect(summary.dailyBudgetProgress, equals(0.0));
    });
  });
}
