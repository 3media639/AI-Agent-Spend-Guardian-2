import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_item.dart';

class AlertsNotifier extends StateNotifier<List<AlertItem>> {
  AlertsNotifier()
      : super([
          AlertItem(
            id: 'alert_1',
            severity: AlertSeverity.warning70,
            message: 'Your monthly spend (\$82.50) has crossed 70% of your \$120.00 budget.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: false,
          ),
          AlertItem(
            id: 'alert_2',
            severity: AlertSeverity.anomalyDetected,
            message: 'Unusual spike detected: Claude 3.5 Sonnet generated 120 calls in 4 minutes.',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            isRead: false,
            relatedProvider: 'Anthropic',
          ),
          AlertItem(
            id: 'alert_3',
            severity: AlertSeverity.info,
            message: 'OpenAI API usage synchronized successfully.',
            timestamp: DateTime.now().subtract(const Duration(hours: 18)),
            isRead: true,
            relatedProvider: 'OpenAI',
          ),
        ]);

  void addAlert(AlertItem alert) {
    state = [alert, ...state];
  }

  void markAsRead(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(isRead: true) else a
    ];
  }

  void markAllAsRead() {
    state = [for (final a in state) a.copyWith(isRead: true)];
  }

  void clearAlerts() {
    state = [];
  }
}

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, List<AlertItem>>((ref) {
  return AlertsNotifier();
});

final unreadAlertsCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider);
  return alerts.where((a) => !a.isRead).length;
});
