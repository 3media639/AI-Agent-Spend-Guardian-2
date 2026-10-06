import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.primaryEmeraldLight : AppColors.primaryEmerald;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background subtle ambient gradients like the user's iOS prototype
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryAccent.withOpacity(isDark ? 0.16 : 0.12),
                    Colors.transparent,
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF786EDC).withOpacity(isDark ? 0.12 : 0.08),
                    Colors.transparent,
                  ],
                ],
              ),
            ),
          ),
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2E36).withOpacity(0.72)
                      : Colors.white.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(
                      icon: CupertinoIcons.house_fill,
                      label: 'Home',
                      index: 0,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                    _buildTabItem(
                      icon: CupertinoIcons.chart_bar_fill,
                      label: 'History',
                      index: 1,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                    // Center Floating Emergency Freeze Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const EmergencyFreezeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: freeze.isFrozen
                              ? AppColors.emergencyRed
                              : (isDark ? AppColors.primaryEmeraldLight : AppColors.primaryEmerald),
                          boxShadow: [
                            BoxShadow(
                              color: (freeze.isFrozen
                                      ? AppColors.emergencyRed
                                      : (isDark ? AppColors.primaryEmeraldLight : AppColors.primaryEmerald))
                                  .withOpacity(0.40),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            freeze.isFrozen ? CupertinoIcons.lock_fill : CupertinoIcons.shield_fill,
                            color: isDark && !freeze.isFrozen ? const Color(0xFF08090B) : Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    _buildTabItem(
                      icon: CupertinoIcons.square_grid_2x2_fill,
                      label: 'Providers',
                      index: 2,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                    _buildTabItem(
                      icon: CupertinoIcons.person_crop_circle_fill,
                      label: 'Profile',
                      index: 3,
                      isDark: isDark,
                      primaryAccent: primaryAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
    required Color primaryAccent,
  }) {
    final isSelected = _currentIndex == index;
    final unselectedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 48,
      onPressed: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? primaryAccent : unselectedColor,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? primaryAccent : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}
