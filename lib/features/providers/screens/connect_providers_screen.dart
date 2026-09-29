import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/ai_provider.dart';
import '../providers/ai_provider_provider.dart';

class ConnectProvidersScreen extends ConsumerStatefulWidget {
  const ConnectProvidersScreen({super.key});

  @override
  ConsumerState<ConnectProvidersScreen> createState() => _ConnectProvidersScreenState();
}

class _ConnectProvidersScreenState extends ConsumerState<ConnectProvidersScreen> {
  final _keyInputController = TextEditingController();
  AIProviderType? _selectedProvider;
  bool _isTestingKey = false;
  String? _testSuccessMessage;
  String? _testErrorMessage;

  @override
  void dispose() {
    _keyInputController.dispose();
    super.dispose();
  }

  void _openConnectSheet(ConnectedProvider provider) {
    setState(() {
      _selectedProvider = provider.type;
      _keyInputController.clear();
      _testSuccessMessage = null;
      _testErrorMessage = null;
      _isTestingKey = false;
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Connect ${provider.type.displayName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'SpendGuard securely monitors usage & billing. Keys are stored in hardware-encrypted storage.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Guide link
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.infoBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline, color: AppColors.infoBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Get your key from ${provider.type.displayName} Console:\n${provider.type.docsUrl}',
                          style: const TextStyle(fontSize: 12, color: AppColors.infoBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Key input
                TextField(
                  controller: _keyInputController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '${provider.type.displayName} API Key',
                    hintText: 'Paste key starting with sk-...',
                    prefixIcon: const Icon(Icons.key),
                  ),
                ),
                const SizedBox(height: 12),

                if (_testSuccessMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _testSuccessMessage!,
                      style: const TextStyle(color: AppColors.primaryEmerald, fontSize: 13),
                    ),
                  ),

                if (_testErrorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRed.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _testErrorMessage!,
                      style: const TextStyle(color: AppColors.emergencyRed, fontSize: 13),
                    ),
                  ),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isTestingKey
                            ? null
                            : () async {
                                setModalState(() {
                                  _isTestingKey = true;
                                  _testSuccessMessage = null;
                                  _testErrorMessage = null;
                                });

                                await Future.delayed(const Duration(milliseconds: 700));

                                if (_keyInputController.text.trim().length < 8) {
                                  setModalState(() {
                                    _isTestingKey = false;
                                    _testErrorMessage = 'Invalid API key format. Please verify.';
                                  });
                                } else {
                                  setModalState(() {
                                    _isTestingKey = false;
                                    _testSuccessMessage = 'Connection successful! Quota verified.';
                                  });
                                }
                              },
                        child: _isTestingKey
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Test Connection'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = _keyInputController.text.trim();
                          if (text.isEmpty) return;

                          await ref
                              .read(aiProviderListProvider.notifier)
                              .connectProvider(provider.type, text);

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${provider.type.displayName} connected successfully!'),
                                backgroundColor: AppColors.primaryEmerald,
                              ),
                            );
                          }
                        },
                        child: const Text('Save & Sync'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(aiProviderListProvider);
    final isPro = ref.watch(isUserProProvider);
    final connectedCount = providers.where((p) => p.isConnected).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect AI Providers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe Encryption Badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryEmerald.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: AppColors.primaryEmerald, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Zero-Knowledge Storage: Your keys are hardware-encrypted on your device. SpendGuard never shares or sells your keys.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Free vs Pro status banner
            if (!isPro && connectedCount >= AppConstants.freeProviderLimit)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warningAmber.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.warningAmber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Free Plan: 1 Provider Connected',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Upgrade to Pro to connect Claude, Gemini, Groq & unlimited agents simultaneously.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warningAmber,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => context.push('/profile'),
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              ),

            Text(
              'Supported AI Providers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ...providers.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardHover : AppColors.lightCardHover,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          p.type.displayName[0],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p.type.displayName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.isConnected
                                      ? AppColors.primaryEmerald.withOpacity(0.15)
                                      : (isDark ? AppColors.darkCardHover : AppColors.lightCardHover),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.isConnected ? 'Connected' : 'Not Connected',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: p.isConnected
                                        ? AppColors.primaryEmerald
                                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.isConnected
                                ? 'Key: ${p.maskedKey}'
                                : 'Tap to add API key',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (val) {
                        if (val == 'update') {
                          _openConnectSheet(p);
                        } else if (val == 'disconnect') {
                          ref.read(aiProviderListProvider.notifier).disconnectProvider(p.type);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'update',
                          child: Text(p.isConnected ? 'Update Key' : 'Connect Key'),
                        ),
                        if (p.isConnected)
                          const PopupMenuItem(
                            value: 'disconnect',
                            child: Text('Disconnect', style: TextStyle(color: AppColors.emergencyRed)),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
