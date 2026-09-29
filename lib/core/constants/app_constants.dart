class AppConstants {
  static const String appName = 'AI Agent Spend Guardian';
  static const String shortName = 'SpendGuard';
  static const String tagline = 'Stop runaway AI bills before they start.';

  // Storage Keys
  static const String keySecuredPrefix = 'spendguard_sec_';
  static const String keyUserPrefs = 'spendguard_prefs';
  static const String keyThemeMode = 'spendguard_theme_mode';

  // Default Budget Limits
  static const double defaultDailyBudget = 10.0;
  static const double defaultMonthlyBudget = 100.0;
  static const double softAlertThresholdLow = 0.70; // 70%
  static const double softAlertThresholdHigh = 0.90; // 90%

  // Pro Subscription Info
  static const String freeTierName = 'SpendGuard Starter';
  static const String proTierName = 'SpendGuard Pro';
  static const double proMonthlyPrice = 9.99;
  static const int freeProviderLimit = 1;

  // Supabase Config Placeholders (can be configured via dart-define or env)
  static const String defaultSupabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String defaultSupabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}

enum AIProviderType {
  openAI,
  anthropic,
  googleGemini,
  groq,
  openRouter;

  String get displayName {
    switch (this) {
      case AIProviderType.openAI:
        return 'OpenAI';
      case AIProviderType.anthropic:
        return 'Anthropic (Claude)';
      case AIProviderType.googleGemini:
        return 'Google Gemini';
      case AIProviderType.groq:
        return 'Groq';
      case AIProviderType.openRouter:
        return 'OpenRouter';
    }
  }

  String get iconKey {
    switch (this) {
      case AIProviderType.openAI:
        return 'openai';
      case AIProviderType.anthropic:
        return 'anthropic';
      case AIProviderType.googleGemini:
        return 'gemini';
      case AIProviderType.groq:
        return 'groq';
      case AIProviderType.openRouter:
        return 'openrouter';
    }
  }

  String get docsUrl {
    switch (this) {
      case AIProviderType.openAI:
        return 'https://platform.openai.com/api-keys';
      case AIProviderType.anthropic:
        return 'https://console.anthropic.com/settings/keys';
      case AIProviderType.googleGemini:
        return 'https://aistudio.google.com/app/apikey';
      case AIProviderType.groq:
        return 'https://console.groq.com/keys';
      case AIProviderType.openRouter:
        return 'https://openrouter.ai/keys';
    }
  }
}
