import '../../../core/constants/app_constants.dart';

class BudgetConfig {
  final double dailyBudget;
  final double monthlyBudget;
  final bool alertAt70;
  final bool alertAt90;
  final bool isHardLimitEnabled;
  final bool pushNotificationsEnabled;
  final bool emailAlertsEnabled;
  final String? alertEmail;
  final DateTime updatedAt;

  const BudgetConfig({
    this.dailyBudget = AppConstants.defaultDailyBudget,
    this.monthlyBudget = AppConstants.defaultMonthlyBudget,
    this.alertAt70 = true,
    this.alertAt90 = true,
    this.isHardLimitEnabled = false,
    this.pushNotificationsEnabled = true,
    this.emailAlertsEnabled = false,
    this.alertEmail,
    required this.updatedAt,
  });

  BudgetConfig copyWith({
    double? dailyBudget,
    double? monthlyBudget,
    bool? alertAt70,
    bool? alertAt90,
    bool? isHardLimitEnabled,
    bool? pushNotificationsEnabled,
    bool? emailAlertsEnabled,
    String? alertEmail,
    DateTime? updatedAt,
  }) {
    return BudgetConfig(
      dailyBudget: dailyBudget ?? this.dailyBudget,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      alertAt70: alertAt70 ?? this.alertAt70,
      alertAt90: alertAt90 ?? this.alertAt90,
      isHardLimitEnabled: isHardLimitEnabled ?? this.isHardLimitEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailAlertsEnabled: emailAlertsEnabled ?? this.emailAlertsEnabled,
      alertEmail: alertEmail ?? this.alertEmail,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_budget': dailyBudget,
      'monthly_budget': monthlyBudget,
      'alert_at_70': alertAt70,
      'alert_at_90': alertAt90,
      'is_hard_limit_enabled': isHardLimitEnabled,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_alerts_enabled': emailAlertsEnabled,
      'alert_email': alertEmail,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BudgetConfig.fromJson(Map<String, dynamic> json) {
    return BudgetConfig(
      dailyBudget: (json['daily_budget'] as num?)?.toDouble() ?? AppConstants.defaultDailyBudget,
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? AppConstants.defaultMonthlyBudget,
      alertAt70: json['alert_at_70'] as bool? ?? true,
      alertAt90: json['alert_at_90'] as bool? ?? true,
      isHardLimitEnabled: json['is_hard_limit_enabled'] as bool? ?? false,
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      emailAlertsEnabled: json['email_alerts_enabled'] as bool? ?? false,
      alertEmail: json['alert_email'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
