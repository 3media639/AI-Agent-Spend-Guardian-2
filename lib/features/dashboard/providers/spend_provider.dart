import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../budget/providers/budget_provider.dart';
import '../../freeze/providers/freeze_provider.dart';
import '../../providers/providers/ai_provider_provider.dart';
import '../models/spend_data.dart';

final dashboardSpendSummaryProvider = Provider<DashboardSpendSummary>((ref) {
  final providers = ref.watch(aiProviderListProvider);
  final budget = ref.watch(budgetProvider);
  final freeze = ref.watch(freezeProvider);

  double totalToday = 0;
  double totalMonth = 0;
  final providerSummaries = <ProviderSpendSummary>[];

  for (final p in providers) {
    if (p.isConnected) {
      totalToday += p.todaySpend;
      totalMonth += p.currentMonthSpend;
    }
  }

  for (final p in providers) {
    if (p.isConnected && totalMonth > 0) {
      final percentage = (p.currentMonthSpend / totalMonth) * 100;
      providerSummaries.add(
        ProviderSpendSummary(
          provider: p.type,
          amountSpent: p.currentMonthSpend,
          percentage: percentage,
          totalRequests: (p.currentMonthSpend * 14).round(),
        ),
      );
    }
  }

  // Daily spend timeline (last 7 days)
  final now = DateTime.now();
  final recentDaily = List.generate(7, (index) {
    final d = now.subtract(Duration(days: 6 - index));
    // Sample distribution with realistic variance
    final base = [4.20, 6.80, 5.10, 8.40, 11.20, 7.30, totalToday][index];
    return DailySpendPoint(
      date: d,
      amount: base,
      requestCount: (base * 18).toInt(),
    );
  });

  // Top model usage breakdown
  final topModels = [
    const ModelUsageMetric(
      modelName: 'gpt-4o',
      provider: AIProviderType.openAI,
      cost: 32.40,
      totalTokens: 1250000,
      promptTokens: 850000,
      completionTokens: 400000,
      callsCount: 420,
    ),
    const ModelUsageMetric(
      modelName: 'claude-3-5-sonnet',
      provider: AIProviderType.anthropic,
      cost: 28.50,
      totalTokens: 980000,
      promptTokens: 620000,
      completionTokens: 360000,
      callsCount: 310,
    ),
    const ModelUsageMetric(
      modelName: 'gemini-1.5-pro',
      provider: AIProviderType.googleGemini,
      cost: 11.20,
      totalTokens: 890000,
      promptTokens: 650000,
      completionTokens: 240000,
      callsCount: 205,
    ),
    const ModelUsageMetric(
      modelName: 'gpt-4o-mini',
      provider: AIProviderType.openAI,
      cost: 10.40,
      totalTokens: 3200000,
      promptTokens: 2400000,
      completionTokens: 800000,
      callsCount: 840,
    ),
  ];

  return DashboardSpendSummary(
    spentToday: totalToday,
    spentThisMonth: totalMonth,
    dailyBudget: budget.dailyBudget,
    monthlyBudget: budget.monthlyBudget,
    recentDailySpend: recentDaily,
    providerBreakdown: providerSummaries,
    topModels: topModels,
    isFrozen: freeze.isFrozen,
    lastRefreshed: DateTime.now(),
  );
});
