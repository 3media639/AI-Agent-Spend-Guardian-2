import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

enum SubscriptionTier {
  free,
  pro,
}

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final SubscriptionTier tier;
  final DateTime memberSince;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.tier = SubscriptionTier.free,
    required this.memberSince,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    SubscriptionTier? tier,
    DateTime? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      tier: tier ?? this.tier,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

class AuthNotifier extends StateNotifier<UserProfile?> {
  AuthNotifier()
      : super(
          UserProfile(
            id: 'usr_demo_8831',
            email: 'alex.developer@example.com',
            displayName: 'Alex Carter',
            tier: SubscriptionTier.free,
            memberSince: DateTime.now().subtract(const Duration(days: 45)),
          ),
        );

  void signInWithEmail(String email, String password) {
    state = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      tier: SubscriptionTier.free,
      memberSince: DateTime.now(),
    );
  }

  void signInWithOAuth(String providerName) {
    state = UserProfile(
      id: 'usr_${providerName}_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@$providerName.com',
      displayName: '$providerName User',
      tier: SubscriptionTier.free,
      memberSince: DateTime.now(),
    );
  }

  void upgradeToPro() {
    if (state != null) {
      state = state!.copyWith(tier: SubscriptionTier.pro);
    }
  }

  void downgradeToFree() {
    if (state != null) {
      state = state!.copyWith(tier: SubscriptionTier.free);
    }
  }

  void signOut() {
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier();
});

final isUserProProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider);
  return user?.tier == SubscriptionTier.pro;
});
