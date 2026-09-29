import 'package:flutter_riverpod/flutter_riverpod.dart';

class FreezeState {
  final bool isFrozen;
  final DateTime? frozenAt;
  final String? reason;
  final bool isHardLimitTriggered;

  const FreezeState({
    this.isFrozen = false,
    this.frozenAt,
    this.reason,
    this.isHardLimitTriggered = false,
  });

  FreezeState copyWith({
    bool? isFrozen,
    DateTime? frozenAt,
    String? reason,
    bool? isHardLimitTriggered,
  }) {
    return FreezeState(
      isFrozen: isFrozen ?? this.isFrozen,
      frozenAt: frozenAt ?? this.frozenAt,
      reason: reason ?? this.reason,
      isHardLimitTriggered: isHardLimitTriggered ?? this.isHardLimitTriggered,
    );
  }
}

class FreezeNotifier extends StateNotifier<FreezeState> {
  FreezeNotifier() : super(const FreezeState());

  void emergencyFreeze({String reason = 'Manual Emergency Freeze pressed by user'}) {
    state = FreezeState(
      isFrozen: true,
      frozenAt: DateTime.now(),
      reason: reason,
      isHardLimitTriggered: false,
    );
  }

  void triggerHardLimitFreeze() {
    state = FreezeState(
      isFrozen: true,
      frozenAt: DateTime.now(),
      reason: 'Hard budget limit reached! AI spend suspended.',
      isHardLimitTriggered: true,
    );
  }

  void unfreeze() {
    state = const FreezeState(
      isFrozen: false,
      frozenAt: null,
      reason: null,
      isHardLimitTriggered: false,
    );
  }
}

final freezeProvider = StateNotifierProvider<FreezeNotifier, FreezeState>((ref) {
  return FreezeNotifier();
});
