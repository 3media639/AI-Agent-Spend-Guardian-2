import 'package:go_router/go_router.dart';
import '../../features/alerts/screens/alerts_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/budget/screens/budget_settings_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/freeze/screens/emergency_freeze_screen.dart';
import '../../features/history/screens/spending_history_screen.dart';
import '../../features/navigation/main_scaffold.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/providers/screens/connect_providers_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: '/providers',
      builder: (context, state) => const ConnectProvidersScreen(),
    ),
    GoRoute(
      path: '/budget',
      builder: (context, state) => const BudgetSettingsScreen(),
    ),
    GoRoute(
      path: '/freeze',
      builder: (context, state) => const EmergencyFreezeScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const SpendingHistoryScreen(),
    ),
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
