import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/freeze_provider.dart';

class EmergencyFreezeScreen extends ConsumerStatefulWidget {
  const EmergencyFreezeScreen({super.key});

  @override
  ConsumerState<EmergencyFreezeScreen> createState() => _EmergencyFreezeScreenState();
}

class _EmergencyFreezeScreenState extends ConsumerState<EmergencyFreezeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showUnfreezeConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unfreeze AI Spending?'),
        content: const Text(
          'Re-enabling AI spending will allow all your connected agents and applications to resume making API calls.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Frozen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
            ),
            onPressed: () {
              ref.read(freezeProvider.notifier).unfreeze();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI spending has been restored.'),
                  backgroundColor: AppColors.primaryEmerald,
                ),
              );
            },
            child: const Text('Confirm Unfreeze'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final freeze = ref.watch(freezeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Kill Switch'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Status Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: freeze.isFrozen
                      ? AppColors.emergencyRed.withOpacity(0.15)
                      : AppColors.primaryEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: freeze.isFrozen ? AppColors.emergencyRed : AppColors.primaryEmerald,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: freeze.isFrozen ? AppColors.emergencyRed : AppColors.primaryEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      freeze.isFrozen ? 'STATUS: FROZEN' : 'STATUS: NORMAL OPERATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: freeze.isFrozen ? AppColors.emergencyRed : AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Big Emergency Freeze Button
              ScaleTransition(
                scale: freeze.isFrozen ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: () {
                    if (freeze.isFrozen) {
                      _showUnfreezeConfirmation();
                    } else {
                      ref.read(freezeProvider.notifier).emergencyFreeze();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('EMERGENCY FREEZE ACTIVATED! AI calls blocked.'),
                          backgroundColor: AppColors.emergencyRed,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: freeze.isFrozen
                          ? AppColors.primaryEmerald
                          : AppColors.emergencyRed,
                      boxShadow: [
                        BoxShadow(
                          color: (freeze.isFrozen
                                  ? AppColors.primaryEmerald
                                  : AppColors.emergencyRed)
                              .withOpacity(0.4),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            freeze.isFrozen ? Icons.lock_open_rounded : Icons.power_settings_new,
                            size: 58,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            freeze.isFrozen ? 'TAP TO\nUNFREEZE' : 'FREEZE ALL\nAI SPEND',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Freeze Timestamp Info
              if (freeze.isFrozen && freeze.frozenAt != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.emergencyRed.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Frozen at ${DateFormat('MMM d, h:mm a').format(freeze.frozenAt!)}',
                        style: const TextStyle(
                          color: AppColors.emergencyRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        freeze.reason ?? 'Emergency stop initiated.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // Explanation Box
              Container(
                padding: const EdgeInsets.all(18),
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
                      'What happens when you Freeze?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildBullet(
                      icon: Icons.block,
                      color: AppColors.emergencyRed,
                      title: 'Immediate Stop to Outbound Calls',
                      desc: 'Connected agents receive instantaneous rejection codes (429/403).',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      icon: Icons.repeat_one,
                      color: AppColors.warningAmber,
                      title: 'Looping Agents Terminated',
                      desc: 'Broken agent retry loops and runaway recursive prompts stop burning tokens.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      icon: Icons.check_circle_outline,
                      color: AppColors.primaryEmerald,
                      title: 'Zero Permanent Loss',
                      desc: 'Your API keys remain safely stored. You can resume spending whenever you are ready.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
