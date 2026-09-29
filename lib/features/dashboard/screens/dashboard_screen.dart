import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../freeze/providers/freeze_provider.dart';
import '../providers/spend_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSpendSummaryProvider);
    final freeze = ref.watch(freezeProvider);
    final unreadAlerts = ref.watch(unreadAlertsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.primaryEmerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('SpendGuard'),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (unreadAlerts > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.emergencyRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Re-trigger refresh of providers
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Emergency Freeze Banner (if frozen) or Quick Freeze Action Card
              if (freeze.isFrozen)
                _buildActiveFreezeBanner(context, ref, isDark)
              else
                _buildNormalStatusCard(context, isDark),

              const SizedBox(height: 16),

              // 2. Primary Spend Hero Cards (Today + This Month)
              _buildSpendHero(context, summary, currency, isDark),

              const SizedBox(height: 16),

              // 3. Monthly Budget Progress Bar
              _buildBudgetProgress(context, summary, currency, isDark),

              const SizedBox(height: 20),

              // 4. Daily Spending Trend Chart
              _buildDailySpendingChart(context, summary, currency, isDark),

              const SizedBox(height: 20),

              // 5. Provider Breakdown Section
              _buildProviderBreakdown(context, summary, currency, isDark),

              const SizedBox(height: 20),

              // 6. Top Spending Models
              _buildTopModelsSection(context, summary, currency, isDark),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFreezeBanner(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emergencyRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emergencyRed, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.emergencyRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI SPENDING FROZEN',
                      style: TextStyle(
                        color: AppColors.emergencyRed,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'All agent calls blocked via Guardian kill-switch.',
                      style: TextStyle(fontSize: 13, color: AppColors.emergencyRedLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.emergencyRed,
                    side: const BorderSide(color: AppColors.emergencyRed),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => context.push('/freeze'),
                  child: const Text('Manage Freeze'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    ref.read(freezeProvider.notifier).unfreeze();
                  },
                  child: const Text('Unfreeze Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNormalStatusCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primaryEmerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Guardian Active • API spending safe',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton.icon(
            onPressed: () => context.push('/freeze'),
            icon: const Icon(Icons.flash_on, size: 16, color: AppColors.emergencyRed),
            label: const Text(
              'Freeze',
              style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendHero(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark) {
    return Row(
      children: [
        // Today Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
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
                      'TODAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryEmerald),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currency.format(summary.spentToday),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget: ${currency.format(summary.dailyBudget)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: summary.isDailyBudgetExceeded
                        ? AppColors.emergencyRed
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // This Month Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(18),
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
                      'THIS MONTH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.infoBlue),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currency.format(summary.spentThisMonth),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cap: ${currency.format(summary.monthlyBudget)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: summary.isMonthlyBudgetExceeded
                        ? AppColors.emergencyRed
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark) {
    final progress = summary.monthlyBudgetProgress;
    final pct = (progress * 100).toInt();
    final isHigh = pct >= 90;
    final isMid = pct >= 70 && !isHigh;

    Color barColor = AppColors.primaryEmerald;
    if (isHigh) barColor = AppColors.emergencyRed;
    else if (isMid) barColor = AppColors.warningAmber;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
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
              const Text(
                'Monthly Budget Usage',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              InkWell(
                onTap: () => context.push('/budget'),
                child: const Text(
                  'Edit Limits',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryEmerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: isDark ? AppColors.darkCardHover : AppColors.lightCardHover,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct% used',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
              Text(
                '${currency.format(summary.monthlyBudget - summary.spentThisMonth)} remaining',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailySpendingChart(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark) {
    final maxAmount = summary.recentDailySpend.fold<double>(
        1.0, (prev, curr) => curr.amount > prev ? curr.amount : prev);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
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
              const Text(
                'Daily Spend (Last 7 Days)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'Avg: \$${(summary.spentThisMonth / 28).toStringAsFixed(2)}/day',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Clean custom bar visualization
          SizedBox(
            height: 130,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday ? AppColors.primaryEmerald : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 80 * ratio,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primaryEmerald
                            : (isDark ? AppColors.darkCardHover : const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
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

  Widget _buildProviderBreakdown(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Spend by Provider',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            InkWell(
              onTap: () => context.push('/providers'),
              child: const Text(
                'Manage Keys',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryEmerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...summary.providerBreakdown.map((item) {
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
              brandColor = AppColors.primaryEmerald;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      item.provider.displayName[0],
                      style: TextStyle(
                        color: brandColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.provider.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '${item.totalRequests} API calls',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      '${item.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTopModelsSection(
      BuildContext context, DashboardSpendSummary summary, NumberFormat currency, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Spending Models',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            InkWell(
              onTap: () => context.push('/history'),
              child: const Text(
                'Full History',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryEmerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...summary.topModels.take(3).map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code, size: 18, color: AppColors.primaryEmerald),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.modelName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          '${(m.totalTokens / 1000).toStringAsFixed(0)}k tokens • ${m.callsCount} calls',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  currency.format(m.cost),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
