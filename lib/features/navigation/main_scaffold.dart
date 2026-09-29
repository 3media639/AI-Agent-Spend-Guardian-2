import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../alerts/providers/alerts_provider.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../freeze/providers/freeze_provider.dart';
import '../freeze/screens/emergency_freeze_screen.dart';
import '../history/screens/spending_history_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../providers/screens/connect_providers_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SpendingHistoryScreen(),
    ConnectProvidersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final freeze = ref.watch(freezeProvider);
    final unreadCount = ref.watch(unreadAlertsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        backgroundColor: freeze.isFrozen ? AppColors.emergencyRed : const Color(0xFFDC2626),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EmergencyFreezeScreen(),
            ),
          );
        },
        child: Icon(
          freeze.isFrozen ? Icons.lock : Icons.power_settings_new,
          color: Colors.white,
          size: 28,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.history_rounded,
                activeIcon: Icons.history_rounded,
                label: 'History',
                index: 1,
              ),
              const SizedBox(width: 48), // Spacer for center docked FAB
              _buildNavItem(
                icon: Icons.hub_outlined,
                activeIcon: Icons.hub_rounded,
                label: 'Providers',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? AppColors.primaryEmerald
                  : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryEmerald
                    : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
