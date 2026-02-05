/// ==========================================================================
/// social_provider.dart
/// ==========================================================================
/// Ijtimoiy tarmoq funksiyalari va leaderboard provider.
/// ==========================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int points;
  final String tier;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.points,
    required this.tier,
  });
}

class SocialState {
  final List<LeaderboardEntry> globalLeaderboard;
  final List<LeaderboardEntry> friendsLeaderboard;
  final bool isPrivacyOptIn;
  final bool isLoading;

  const SocialState({
    this.globalLeaderboard = const [],
    this.friendsLeaderboard = const [],
    this.isPrivacyOptIn = true,
    this.isLoading = false,
  });

  SocialState copyWith({
    List<LeaderboardEntry>? globalLeaderboard,
    List<LeaderboardEntry>? friendsLeaderboard,
    bool? isPrivacyOptIn,
    bool? isLoading,
  }) {
    return SocialState(
      globalLeaderboard: globalLeaderboard ?? this.globalLeaderboard,
      friendsLeaderboard: friendsLeaderboard ?? this.friendsLeaderboard,
      isPrivacyOptIn: isPrivacyOptIn ?? this.isPrivacyOptIn,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SocialNotifier extends StateNotifier<SocialState> {
  SocialNotifier() : super(const SocialState()) {
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true);

    // Demo data for leaderboard
    await Future.delayed(const Duration(milliseconds: 800));

    final demoEntries = [
      const LeaderboardEntry(
          userId: '1', displayName: 'Aziz', points: 15400, tier: 'Platinum'),
      const LeaderboardEntry(
          userId: '2', displayName: 'Malika', points: 12100, tier: 'Platinum'),
      const LeaderboardEntry(
          userId: '3', displayName: 'Sherzod', points: 8500, tier: 'Gold'),
      const LeaderboardEntry(
          userId: '4', displayName: 'Davron', points: 7200, tier: 'Gold'),
      const LeaderboardEntry(
          userId: '5', displayName: 'Jasur', points: 5100, tier: 'Gold'),
      const LeaderboardEntry(
          userId: '6', displayName: 'Laylo', points: 4300, tier: 'Silver'),
      const LeaderboardEntry(
          userId: '7', displayName: 'Nozim', points: 3900, tier: 'Silver'),
    ];

    state = state.copyWith(
      globalLeaderboard: demoEntries,
      isLoading: false,
    );
  }

  void togglePrivacy(bool val) {
    state = state.copyWith(isPrivacyOptIn: val);
    // Real ilovada Firestore'dagi user field yangilanadi
  }
}

final socialProvider =
    StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  return SocialNotifier();
});
