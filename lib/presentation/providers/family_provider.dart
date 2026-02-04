/// ==========================================================================
/// family_provider.dart
/// ==========================================================================
/// Oilaviy guruh va umumiy hamyon provideri.
/// ==========================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/repositories/family_repository.dart'; // Temporarily commented out
import '../../domain/entities/family_group.dart';
import 'auth_provider.dart'; // Ensure authProvider is available
import '../../core/utils/extensions.dart'; // Add extensions for .user

class FamilyState {
  final FamilyGroup? group;
  final bool isLoading;
  final String? error;

  const FamilyState({
    this.group,
    this.isLoading = false,
    this.error,
  });

  FamilyState copyWith({
    FamilyGroup? group,
    bool? isLoading,
    String? error,
  }) {
    return FamilyState(
      group: group ?? this.group,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FamilyNotifier extends StateNotifier<FamilyState> {
  final Ref _ref;

  FamilyNotifier(this._ref) : super(const FamilyState()) {
    _loadFamilyGroup();
  }

  Future<void> _loadFamilyGroup() async {
    state = state.copyWith(isLoading: true);

    // Demo logic: 800ms delay
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _ref.read(authProvider).user;
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    // Mock family group
    final mockGroup = FamilyGroup(
      id: 'fam_1',
      name: 'Sherzodovlar Oilasi',
      adminId: user.uid,
      sharedWalletBalance: 5000,
      members: [
        FamilyMember(
            id: user.uid,
            displayName: user.displayName ?? 'Siz',
            role: 'admin',
            contributedPoints: 3200),
        const FamilyMember(
            id: 'member_2',
            displayName: 'Laylo',
            role: 'member',
            contributedPoints: 1200),
        const FamilyMember(
            id: 'member_3',
            displayName: 'Jasur',
            role: 'member',
            contributedPoints: 600),
      ],
    );

    state = state.copyWith(group: mockGroup, isLoading: false);
  }

  Future<void> contributePoints(int points) async {
    if (state.group == null) return;

    // Haqiqiy ilovada tranzaksiya amalga oshadi
    final updatedGroup = state.group!.copyWith(
      sharedWalletBalance: state.group!.sharedWalletBalance + points,
    );

    state = state.copyWith(group: updatedGroup);
  }
}

final familyProvider =
    StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier(ref);
});
