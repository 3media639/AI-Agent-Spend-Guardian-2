import '../../../core/constants/app_constants.dart';

class ConnectedProvider {
  final String id;
  final AIProviderType type;
  final bool isConnected;
  final String? maskedKey;
  final DateTime? lastSyncedAt;
  final double currentMonthSpend;
  final double todaySpend;
  final String? errorMessage;
  final bool isFrozen;

  const ConnectedProvider({
    required this.id,
    required this.type,
    this.isConnected = false,
    this.maskedKey,
    this.lastSyncedAt,
    this.currentMonthSpend = 0.0,
    this.todaySpend = 0.0,
    this.errorMessage,
    this.isFrozen = false,
  });

  ConnectedProvider copyWith({
    String? id,
    AIProviderType? type,
    bool? isConnected,
    String? maskedKey,
    DateTime? lastSyncedAt,
    double? currentMonthSpend,
    double? todaySpend,
    String? errorMessage,
    bool? isFrozen,
  }) {
    return ConnectedProvider(
      id: id ?? this.id,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
      maskedKey: maskedKey ?? this.maskedKey,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      currentMonthSpend: currentMonthSpend ?? this.currentMonthSpend,
      todaySpend: todaySpend ?? this.todaySpend,
      errorMessage: errorMessage ?? this.errorMessage,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'is_connected': isConnected,
      'masked_key': maskedKey,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'current_month_spend': currentMonthSpend,
      'today_spend': todaySpend,
      'is_frozen': isFrozen,
    };
  }

  factory ConnectedProvider.fromJson(Map<String, dynamic> json) {
    return ConnectedProvider(
      id: json['id'] as String,
      type: AIProviderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AIProviderType.openAI,
      ),
      isConnected: json['is_connected'] as bool? ?? false,
      maskedKey: json['masked_key'] as String?,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.tryParse(json['last_synced_at'] as String)
          : null,
      currentMonthSpend: (json['current_month_spend'] as num?)?.toDouble() ?? 0.0,
      todaySpend: (json['today_spend'] as num?)?.toDouble() ?? 0.0,
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }
}
