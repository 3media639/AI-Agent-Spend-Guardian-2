import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../providers/providers/ai_provider_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showUpgradeSheet(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO MEMBERSHIP',
                      style: TextStyle(
                        color: AppColors.primaryEmerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Unlock Unlimited Peace of Mind',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Control all your agents and API keys without restrictions.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Feature list
              _buildProBenefit(Icons.check, 'Connect Unlimited AI Providers & Models'),
              _buildProBenefit(Icons.check, 'Automatic Hard Limit Kill Switch'),
              _buildProBenefit(Icons.check, 'Unlimited Spending History & CSV Exports'),
              _buildProBenefit(Icons.check, 'Real-time Webhook & Telegram Alerts'),
              _buildProBenefit(Icons.check, 'Sub-second Emergency Freeze Gateway'),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).upgradeToPro();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Upgraded to SpendGuard Pro! Thank you!'),
                      backgroundColor: AppColors.primaryEmerald,
                    ),
                  );
                },
                child: Text('Upgrade to Pro • \$${AppConstants.proMonthlyPrice}/month'),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Cancel anytime with 1-click in App Store / Play Store.',
                  style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildProBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: AppColors.primaryEmerald),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your user profile and purge all locally encrypted API keys. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
              context.go('/auth');
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final providers = ref.watch(aiProviderListProvider);
    final connectedCount = providers.where((p) => p.isConnected).length;
    final isPro = user?.tier == SubscriptionTier.pro;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryEmerald.withOpacity(0.2),
                    child: Text(
                      user != null && user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Guest User',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? 'Not logged in',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPro
                          ? AppColors.primaryEmerald.withOpacity(0.15)
                          : (isDark ? AppColors.darkCardHover : AppColors.lightCardHover),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPro ? 'PRO' : 'FREE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPro ? AppColors.primaryEmerald : AppColors.darkTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Plan Membership Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPro
                      ? [const Color(0xFF064E3B), const Color(0xFF047857)]
                      : (isDark
                          ? [AppColors.darkCard, AppColors.darkCardHover]
                          : [AppColors.lightCard, AppColors.lightCardHover]),
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPro ? AppColors.primaryEmerald : AppColors.darkBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isPro ? 'SpendGuard Pro Plan' : 'Free Starter Plan',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        isPro ? Icons.verified : Icons.lock_outline,
                        color: isPro ? Colors.white : AppColors.warningAmber,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPro
                        ? 'Unlimited providers active. Priority push notifications enabled.'
                        : 'Limited to 1 connected provider. Basic alert thresholds.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isPro ? Colors.white.withOpacity(0.9) : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!isPro)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                      ),
                      onPressed: () => _showUpgradeSheet(context, ref, isDark),
                      child: const Text('Upgrade to Pro • \$9.99/mo'),
                    )
                  else
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () {
                        ref.read(authProvider.notifier).downgradeToFree();
                      },
                      child: const Text('Manage Subscription'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preferences & Navigation
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.hub_outlined),
                    title: const Text('Connected Providers'),
                    trailing: Text('$connectedCount active', style: const TextStyle(fontSize: 13)),
                    onTap: () => context.push('/providers'),
                  ),
                  Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ListTile(
                    leading: const Icon(Icons.tune_outlined),
                    title: const Text('Budget Limits & Alerts'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/budget'),
                  ),
                  Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Alert Notifications'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push('/alerts'),
                  ),
                  Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ListTile(
                    leading: const Icon(Icons.flash_on_outlined, color: AppColors.emergencyRed),
                    title: const Text('Emergency Kill Switch', style: TextStyle(color: AppColors.emergencyRed)),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.emergencyRed),
                    onTap: () => context.push('/freeze'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout & Delete Actions
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/auth');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context, ref),
                child: const Text(
                  'Delete Account & Purge Keys',
                  style: TextStyle(color: AppColors.emergencyRed, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
