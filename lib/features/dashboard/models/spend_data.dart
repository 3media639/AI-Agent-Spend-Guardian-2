import '../../../core/constants/app_constants.dart';

class DailySpendPoint {
  final DateTime date;
  final double amount;
  final int requestCount;

  const DailySpendPoint({
    required this.date,
    required this.amount,
    this.requestCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
        'request_count': requestCount,
      };

  factory DailySpendPoint.fromJson(Map<String, dynamic> json) => DailySpendPoint(
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        requestCount: json['request_count'] as int? ?? 0,
      );
}

class ProviderSpendSummary {
  final AIProviderType provider;
  final double amountSpent;
  final double percentage;
  final int totalRequests;

  const ProviderSpendSummary({
    required this.provider,
    required this.amountSpent,
    required this.percentage,
    required this.totalRequests,
  });
}

class ModelUsageMetric {
  final String modelName;
  final AIProviderType provider;
  final double cost;
  final int totalTokens;
  final int promptTokens;
  final int completionTokens;
  final int callsCount;

  const ModelUsageMetric({
    required this.modelName,
    required this.provider,
    required this.cost,
    required this.totalTokens,
    required this.promptTokens,
    required this.completionTokens,
    required this.callsCount,
  });
}

class DashboardSpendSummary {
  final double spentToday;
  final double spentThisMonth;
  final double dailyBudget;
  final double monthlyBudget;
  final List<DailySpendPoint> recentDailySpend;
  final List<ProviderSpendSummary> providerBreakdown;
  final List<ModelUsageMetric> topModels;
  final bool isFrozen;
  final DateTime lastRefreshed;

  const DashboardSpendSummary({
    required this.spentToday,
    required this.spentThisMonth,
    required this.dailyBudget,
    required this.monthlyBudget,
    required this.recentDailySpend,
    required this.providerBreakdown,
    required this.topModels,
    required this.isFrozen,
    required this.lastRefreshed,
  });

  double get monthlyBudgetProgress =>
      monthlyBudget > 0 ? (spentThisMonth / monthlyBudget).clamp(0.0, 1.5) : 0.0;

  double get dailyBudgetProgress =>
      dailyBudget > 0 ? (spentToday / dailyBudget).clamp(0.0, 1.5) : 0.0;

  bool get isMonthlyBudgetExceeded => spentThisMonth >= monthlyBudget;
  bool get isDailyBudgetExceeded => spentToday >= dailyBudget;
}
