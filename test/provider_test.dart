import 'package:flutter_test/flutter_test.dart';
import 'package:spendguard/core/constants/app_constants.dart';
import 'package:spendguard/features/providers/models/ai_provider.dart';

void main() {
  group('ConnectedProvider Tests', () {
    test('ConnectedProvider serialization and copyWith works properly', () {
      final original = ConnectedProvider(
        id: 'openai_1',
        type: AIProviderType.openAI,
        isConnected: true,
        maskedKey: 'sk-proj-••••4a8F',
        todaySpend: 4.5,
        currentMonthSpend: 45.0,
      );

      final modified = original.copyWith(todaySpend: 5.2);
      expect(modified.todaySpend, equals(5.2));
      expect(modified.type, equals(AIProviderType.openAI));
      expect(modified.isConnected, isTrue);

      final json = original.toJson();
      expect(json['type'], equals('openAI'));
      expect(json['is_connected'], isTrue);

      final restored = ConnectedProvider.fromJson(json);
      expect(restored.id, equals('openai_1'));
      expect(restored.currentMonthSpend, equals(45.0));
    });
  });
}
