import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/budget_provider.dart';

class BudgetSettingsScreen extends ConsumerStatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  ConsumerState<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends ConsumerState<BudgetSettingsScreen> {
  late TextEditingController _dailyController;
  late TextEditingController _monthlyController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(budgetProvider);
    _dailyController = TextEditingController(text: config.dailyBudget.toStringAsFixed(0));
    _monthlyController = TextEditingController(text: config.monthlyBudget.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    final daily = double.tryParse(_dailyController.text.trim()) ?? 10.0;
    final monthly = double.tryParse(_monthlyController.text.trim()) ?? 100.0;

    ref.read(budgetProvider.notifier).updateBudgets(
          dailyBudget: daily,
          monthlyBudget: monthly,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget limits updated successfully!'),
        backgroundColor: AppColors.primaryEmerald,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(budgetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Spending Limits'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanatory Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.primaryEmerald, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Set safety boundaries so unexpected agent iterations never cause runaway billing.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily & Monthly Budget Inputs
            Text(
              'Budget Limits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _dailyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Daily Spending Limit',
                      prefixText: '\$ ',
                      helperText: 'Recommended: \$10 - \$25 / day',
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _monthlyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monthly Spending Limit',
                      prefixText: '\$ ',
                      helperText: 'Maximum spending allowed across all providers per billing month.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Soft Alert Settings
            Text(
              'Alert Thresholds (Soft Alerts)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Warning at 70% of Budget',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Sends push notification and email alert as an early warning.',
                        style: TextStyle(fontSize: 12)),
                    value: config.alertAt70,
                    activeColor: AppColors.warningAmber,
                    onChanged: (val) {
                      ref.read(budgetProvider.notifier).toggleAlert70(val);
                    },
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  SwitchListTile(
                    title: const Text('Critical Warning at 90% of Budget',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Urgent notice that your budget is almost exhausted.',
                        style: TextStyle(fontSize: 12)),
                    value: config.alertAt90,
                    activeColor: AppColors.emergencyRed,
                    onChanged: (val) {
                      ref.read(budgetProvider.notifier).toggleAlert90(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hard Limit Toggle
            Text(
              'Automatic Kill-Switch (Hard Limit)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: config.isHardLimitEnabled
                    ? AppColors.emergencyRed.withOpacity(0.08)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: config.isHardLimitEnabled
                      ? AppColors.emergencyRed
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Enforce Hard Limit Freeze',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Instantly halts agent requests when the monthly or daily limit is reached to prevent any further charges.',
                  style: TextStyle(fontSize: 12.5),
                ),
                value: config.isHardLimitEnabled,
                activeColor: AppColors.emergencyRed,
                onChanged: (val) {
                  ref.read(budgetProvider.notifier).toggleHardLimit(val);
                },
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveBudget,
              child: const Text('Save Budget Settings'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
