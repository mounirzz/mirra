import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';

class StreakState {
  const StreakState({required this.count, required this.justIncreased});

  final int count;

  /// True only for the session where the streak just went up — lets the UI
  /// play the flame celebration exactly once.
  final bool justIncreased;
}

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier()
    : super(
        StreakState(count: MirraBoxes.current.streak, justIncreased: false),
      );

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Called once at app startup. Rule (validated with the user, TikTok/
  /// Snapchat-style): opening on consecutive days grows the flame; short
  /// absences (1-2 missed days) keep it alive; from the 3rd missed day the
  /// flame dies and the streak restarts at 1.
  Future<void> checkIn({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final prefs = MirraBoxes.current;
    final last = prefs.lastOpenDate != null
        ? DateTime.tryParse(prefs.lastOpenDate!)
        : null;

    int newStreak;
    if (last == null) {
      newStreak = prefs.streak > 0 ? prefs.streak : 1;
    } else {
      final gap = DateTime(
        today.year,
        today.month,
        today.day,
      ).difference(DateTime(last.year, last.month, last.day)).inDays;
      if (gap == 0) {
        return; // already checked in today
      }
      final missedDays = gap - 1;
      newStreak = missedDays >= 3 ? 1 : prefs.streak + 1;
    }

    final increased = newStreak > prefs.streak;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(streak: newStreak, lastOpenDate: _dayKey(today)),
    );
    state = StreakState(count: newStreak, justIncreased: increased);
  }

  void dismissCelebration() {
    if (state.justIncreased) {
      state = StreakState(count: state.count, justIncreased: false);
    }
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakState>(
  (ref) => StreakNotifier(),
);

/// Local, offline "interactive flame" total. Every like/share/copy bumps it up
/// instantly and persists it, so the 🔥 badge grows as the user engages —
/// independent of sign-in or the server-backed engagement level.
class LocalFlamesState {
  const LocalFlamesState({required this.count, required this.lastDelta});

  final int count;

  /// The size of the most recent bump (for a one-shot "+N" flourish). 0 when
  /// nothing just happened.
  final int lastDelta;
}

class LocalFlamesNotifier extends StateNotifier<LocalFlamesState> {
  LocalFlamesNotifier()
      : super(
          LocalFlamesState(
            count: MirraBoxes.current.flamePoints,
            lastDelta: 0,
          ),
        );

  /// Points awarded per engagement action.
  static int pointsFor(String action) {
    switch (action) {
      case 'like':
        return 1;
      case 'share':
        return 2; // sharing spreads Mirra → worth a little more
      case 'copy':
        return 1;
      default:
        return 0;
    }
  }

  Future<void> bump(String action) async {
    final delta = pointsFor(action);
    if (delta == 0) return;
    final next = state.count + delta;
    await MirraBoxes.updatePrefs((p) => p.copyWith(flamePoints: next));
    state = LocalFlamesState(count: next, lastDelta: delta);
  }

  /// Clears the one-shot delta after the UI has played its flourish.
  void clearDelta() {
    if (state.lastDelta != 0) {
      state = LocalFlamesState(count: state.count, lastDelta: 0);
    }
  }
}

final localFlamesProvider =
    StateNotifierProvider<LocalFlamesNotifier, LocalFlamesState>(
  (ref) => LocalFlamesNotifier(),
);
