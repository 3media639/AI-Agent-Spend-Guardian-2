import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../budget/providers/budget_provider.dart';
import '../models/alert_item.dart';
import '../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final budgetConfig = ref.watch(budgetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        actions: [
          if (alerts.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(alertsProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notification Channels Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Channels',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push Notifications', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Instant alerts on your phone lock screen',
                        style: TextStyle(fontSize: 12)),
                    value: budgetConfig.pushNotificationsEnabled,
                    activeColor: AppColors.primaryEmerald,
                    onChanged: (val) {
                      ref.read(budgetProvider.notifier).updateNotificationSettings(pushEnabled: val);
                    },
                  ),
                  Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Email Alerts', style: TextStyle(fontSize: 14)),
                    subtitle: Text('Sent to: ${budgetConfig.alertEmail ?? "Not configured"}',
                        style: const TextStyle(fontSize: 12)),
                    value: budgetConfig.emailAlertsEnabled,
                    activeColor: AppColors.primaryEmerald,
                    onChanged: (val) {
                      ref.read(budgetProvider.notifier).updateNotificationSettings(emailEnabled: val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Notification History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Alerts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (alerts.isNotEmpty)
                  InkWell(
                    onTap: () {
                      ref.read(alertsProvider.notifier).clearAlerts();
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (alerts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(height: 12),
                    const Text('No alerts right now. All budgets are healthy!'),
                  ],
                ),
              )
            else
              ...alerts.map((a) {
                Color iconColor;
                IconData iconData;

                switch (a.severity) {
                  case AlertSeverity.emergencyFreeze:
                  case AlertSeverity.hardLimitReached:
                    iconColor = AppColors.emergencyRed;
                    iconData = Icons.power_settings_new;
                    break;
                  case AlertSeverity.warning90:
                    iconColor = AppColors.emergencyRed;
                    iconData = Icons.warning_amber_rounded;
                    break;
                  case AlertSeverity.warning70:
                    iconColor = AppColors.warningAmber;
                    iconData = Icons.info_outline;
                    break;
                  case AlertSeverity.anomalyDetected:
                    iconColor = AppColors.warningAmber;
                    iconData = Icons.electric_bolt;
                    break;
                  case AlertSeverity.info:
                    iconColor = AppColors.infoBlue;
                    iconData = Icons.check_circle_outline;
                    break;
                }

                return GestureDetector(
                  onTap: () => ref.read(alertsProvider.notifier).markAsRead(a.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: a.isRead
                          ? (isDark ? AppColors.darkCard : AppColors.lightCard)
                          : (isDark ? AppColors.darkCardHover : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: !a.isRead
                            ? iconColor.withOpacity(0.5)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.severity.title,
                                      style: TextStyle(
                                        fontWeight: a.isRead ? FontWeight.w600 : FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM d, h:mm a').format(a.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                a.message,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
