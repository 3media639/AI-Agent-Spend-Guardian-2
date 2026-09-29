enum AlertSeverity {
  info,
  warning70,
  warning90,
  hardLimitReached,
  emergencyFreeze,
  anomalyDetected;

  String get title {
    switch (this) {
      case AlertSeverity.info:
        return 'System Notification';
      case AlertSeverity.warning70:
        return 'Budget Alert: 70% Reached';
      case AlertSeverity.warning90:
        return 'Urgent: 90% of Budget Used';
      case AlertSeverity.hardLimitReached:
        return 'Hard Limit Reached - Auto Frozen';
      case AlertSeverity.emergencyFreeze:
        return 'Emergency Freeze Activated';
      case AlertSeverity.anomalyDetected:
        return 'Spending Anomaly Detected';
    }
  }
}

class AlertItem {
  final String id;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedProvider;

  const AlertItem({
    required this.id,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedProvider,
  });

  AlertItem copyWith({
    String? id,
    AlertSeverity? severity,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? relatedProvider,
  }) {
    return AlertItem(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedProvider: relatedProvider ?? this.relatedProvider,
    );
  }
}
