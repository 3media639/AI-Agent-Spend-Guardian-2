import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/security/encryption_service.dart';
import '../models/ai_provider.dart';

class AIProviderNotifier extends StateNotifier<List<ConnectedProvider>> {
  final EncryptionService _encryptionService;

  AIProviderNotifier({EncryptionService? encryptionService})
      : _encryptionService = encryptionService ?? EncryptionService(),
        super([
          ConnectedProvider(
            id: 'openai_default',
            type: AIProviderType.openAI,
            isConnected: true,
            maskedKey: 'sk-proj-••••••••4a8F',
            lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 4)),
            currentMonthSpend: 42.80,
            todaySpend: 3.40,
          ),
          ConnectedProvider(
            id: 'anthropic_default',
            type: AIProviderType.anthropic,
            isConnected: true,
            maskedKey: 'sk-ant-••••••••99xQ',
            lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 12)),
            currentMonthSpend: 28.50,
            todaySpend: 4.15,
          ),
          ConnectedProvider(
            id: 'gemini_default',
            type: AIProviderType.googleGemini,
            isConnected: true,
            maskedKey: 'AIzaSy••••••••K7Lm',
            lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 25)),
            currentMonthSpend: 11.20,
            todaySpend: 0.95,
          ),
          const ConnectedProvider(
            id: 'groq_default',
            type: AIProviderType.groq,
            isConnected: false,
            maskedKey: null,
            currentMonthSpend: 0.0,
            todaySpend: 0.0,
          ),
          const ConnectedProvider(
            id: 'openrouter_default',
            type: AIProviderType.openRouter,
            isConnected: false,
            maskedKey: null,
            currentMonthSpend: 0.0,
            todaySpend: 0.0,
          ),
        ]);

  Future<bool> connectProvider(AIProviderType type, String rawApiKey) async {
    if (rawApiKey.trim().isEmpty) return false;

    // Simulate/Perform secure validation
    final masked = _maskApiKey(rawApiKey.trim());
    await _encryptionService.storeApiKey(type.name, rawApiKey.trim());

    state = [
      for (final p in state)
        if (p.type == type)
          p.copyWith(
            isConnected: true,
            maskedKey: masked,
            lastSyncedAt: DateTime.now(),
            errorMessage: null,
          )
        else
          p
    ];
    return true;
  }

  Future<void> disconnectProvider(AIProviderType type) async {
    await _encryptionService.deleteApiKey(type.name);
    state = [
      for (final p in state)
        if (p.type == type)
          p.copyWith(
            isConnected: false,
            maskedKey: null,
            lastSyncedAt: null,
            currentMonthSpend: 0.0,
            todaySpend: 0.0,
          )
        else
          p
    ];
  }

  String _maskApiKey(String key) {
    if (key.length <= 8) return '••••••••';
    final prefix = key.substring(0, key.length > 7 ? 7 : 3);
    final suffix = key.substring(key.length - 4);
    return '$prefix••••$suffix';
  }
}

final aiProviderListProvider =
    StateNotifierProvider<AIProviderNotifier, List<ConnectedProvider>>((ref) {
  return AIProviderNotifier();
});
