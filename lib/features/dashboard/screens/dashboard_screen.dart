import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../freeze/providers/freeze_provider.dart';
import '../models/spend_data.dart';
import '../providers/spend_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSpendSummaryProvider);
    final freeze = ref.watch(freezeProvider);
    final unreadAlerts = ref.watch(unreadAlertsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.primaryEmeraldLight : AppColors.primaryEmerald;
    final currency = NumberFormat.currency(symbol: '\$');
    final todayStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: primaryAccent,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row (Date & Notifications/Settings)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      todayStr,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        // Alert Bell with Badge
                        GestureDetector(
                          onTap: () => context.push('/alerts'),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : Colors.white,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                                child: Icon(
                                  CupertinoIcons.bell_fill,
                                  size: 18,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              if (unreadAlerts > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.emergencyRed,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '$unreadAlerts',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quick Settings
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.gear_alt_fill,
                              size: 18,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Large iOS Title: Good morning / Spend Guardian
                Text(
                  'Spend Guardian',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // 1. Autopilot Smart Guardian Card (Life Admin inspired banner)
                if (freeze.isFrozen)
                  _buildActiveFreezeCard(context, ref, isDark)
                else
                  _buildAutopilotGuardianCard(context, ref, isDark, primaryAccent),

                const SizedBox(height: 20),

                // 2. Spending Ring & Hero Metrics
                _buildHeroSpendRing(context, summary, currency, isDark, primaryAccent),

                const SizedBox(height: 20),

                // 3. Quick Spend Stats Grid (2 Tiles: Today & This Month)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'Today Spent',
                        value: currency.format(summary.spentToday),
                        subtext: 'Limit ${currency.format(summary.dailyBudget)}',
                        icon: CupertinoIcons.today,
                        isDark: isDark,
                        badgeColor: summary.isDailyBudgetExceeded
                            ? AppColors.emergencyRed
                            : primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'This Month',
                        value: currency.format(summary.spentThisMonth),
                        subtext: 'Cap ${currency.format(summary.monthlyBudget)}',
                        icon: CupertinoIcons.calendar,
                        isDark: isDark,
                        badgeColor: summary.isMonthlyBudgetExceeded
                            ? AppColors.emergencyRed
                            : AppColors.infoBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Daily Spend Trend (Last 7 Days Bar Visualizer)
                _buildDailyTrendCard(context, summary, currency, isDark, primaryAccent),

                const SizedBox(height: 24),

                // 5. Providers Section (iOS List Row Style)
                _buildSectionHeader(
                  title: 'Connected Providers',
                  actionText: 'Manage',
                  onTap: () => context.push('/providers'),
                  isDark: isDark,
                  primaryAccent: primaryAccent,
                ),
                const SizedBox(height: 10),
                _buildProvidersList(context, summary, currency, isDark, primaryAccent),

                const SizedBox(height: 24),

                // 6. Top AI Models Section
                _buildSectionHeader(
                  title: 'Active Models',
                  actionText: 'History',
                  onTap: () => context.push('/history'),
                  isDark: isDark,
                  primaryAccent: primaryAccent,
                ),
                const SizedBox(height: 10),
                _buildTopModelsList(context, summary, currency, isDark, primaryAccent),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutopilotGuardianCard(
      BuildContext context, WidgetRef ref, bool isDark, Color primaryAccent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Color.alphaBlend(primaryAccent.withOpacity(0.12), AppColors.darkCard)
            : Color.alphaBlend(primaryAccent.withOpacity(0.08), Colors.white),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primaryAccent.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.sparkles, size: 17, color: primaryAccent),
              const SizedBox(width: 8),
              Text(
                'Guardian Autopilot',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryAccent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreenSurface,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: AppColors.successGreen),
                    SizedBox(width: 5),
                    Text(
                      'Live Guard',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'All agents operating within safety limits.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hard stop killswitch primed. Auto-protect active.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: primaryAccent,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => context.push('/budget'),
                  child: Text(
                    'Budget Rules',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF08090B) : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.emergencyRedSurface,
                borderRadius: BorderRadius.circular(14),
                onPressed: () => context.push('/freeze'),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.lock_fill, size: 14, color: AppColors.emergencyRed),
                    SizedBox(width: 6),
                    Text(
                      'Freeze',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFreezeCard(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.emergencyRedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.emergencyRed, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.lock_shield_fill, color: AppColors.emergencyRed, size: 22),
              SizedBox(width: 10),
              Text(
                'AI SPENDING FROZEN',
                style: TextStyle(
                  color: AppColors.emergencyRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'All agent calls blocked via Guardian kill-switch. Your budgets are completely protected.',
            style: TextStyle(fontSize: 13, color: AppColors.emergencyRedLight),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => context.push('/freeze'),
                  child: const Text(
                    'Manage Freeze',
                    style: TextStyle(
                      color: AppColors.emergencyRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () => ref.read(freezeProvider.notifier).unfreeze(),
                  child: const Text(
                    'Unfreeze Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSpendRing(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark, Color primaryAccent) {
    final pct = (summary.monthlyBudgetProgress * 100).toInt();
    final remaining = (summary.monthlyBudget - summary.spentThisMonth).clamp(0.0, 999999.0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardTranslucent : AppColors.lightCardTranslucent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Consumption',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pct >= 90
                      ? AppColors.emergencyRedSurface
                      : (pct >= 70 ? AppColors.warningAmberSurface : AppColors.primaryTealSurface),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$pct% Used',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: pct >= 90
                        ? AppColors.emergencyRed
                        : (pct >= 70 ? AppColors.warningAmber : primaryAccent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Circular Progress Indicator Center Piece
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 145,
                height: 145,
                child: CircularProgressIndicator(
                  value: summary.monthlyBudgetProgress.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  backgroundColor: isDark ? const Color(0xFF26272F) : const Color(0xFFE2E5EC),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct >= 90
                        ? AppColors.emergencyRed
                        : (pct >= 70 ? AppColors.warningAmber : primaryAccent),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currency.format(remaining),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'remaining',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Cap: ${currency.format(summary.monthlyBudget)} / month • Resets in 24 days',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required bool isDark,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardTranslucent : AppColors.lightCardTranslucent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: badgeColor, size: 19),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTrendCard(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark, Color primaryAccent) {
    final maxAmount = summary.recentDailySpend.fold<double>(
        1.0, (prev, curr) => curr.amount > prev ? curr.amount : prev);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardTranslucent : AppColors.lightCardTranslucent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trend (7 Days)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'Avg: \$${(summary.spentThisMonth / 28).toStringAsFixed(1)}/d',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: summary.recentDailySpend.map((point) {
                final ratio = (point.amount / maxAmount).clamp(0.08, 1.0);
                final dayLabel = DateFormat('E').format(point.date);
                final isToday = DateFormat('yyyy-MM-dd').format(point.date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '\$${point.amount.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? primaryAccent
                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 22,
                      height: (75 * ratio).toDouble(),
                      decoration: BoxDecoration(
                        color: isToday
                            ? primaryAccent
                            : (isDark ? const Color(0xFF2C2E36) : const Color(0xFFD6DAE2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryAccent,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersList(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark, Color primaryAccent) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardTranslucent : AppColors.lightCardTranslucent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: summary.providerBreakdown.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == summary.providerBreakdown.length - 1;

          Color brandColor;
          switch (item.provider) {
            case AIProviderType.openAI:
              brandColor = AppColors.providerOpenAI;
              break;
            case AIProviderType.anthropic:
              brandColor = AppColors.providerClaude;
              break;
            case AIProviderType.googleGemini:
              brandColor = AppColors.providerGemini;
              break;
            case AIProviderType.groq:
              brandColor = AppColors.providerGroq;
              break;
            default:
              brandColor = primaryAccent;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: isLast
                    ? BorderSide.none
                    : BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.8,
                      ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      item.provider.displayName[0],
                      style: TextStyle(
                        color: brandColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.provider.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '${item.totalRequests} API calls',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currency.format(item.amountSpent),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '${item.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopModelsList(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark, Color primaryAccent) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardTranslucent : AppColors.lightCardTranslucent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: summary.topModels.take(3).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final model = entry.value;
          final isLast = index == 2 || index == summary.topModels.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: isLast
                    ? BorderSide.none
                    : BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.8,
                      ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    CupertinoIcons.sparkles,
                    size: 18,
                    color: primaryAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.modelName,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '${(model.totalTokens / 1000).toStringAsFixed(0)}k tokens • ${model.callsCount} calls',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currency.format(model.cost),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
