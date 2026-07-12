import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/hive_boxes.dart';

class OnboardingNotifier extends StateNotifier<Map<String, String>> {
  OnboardingNotifier() : super({...MirraBoxes.current.answers});

  /// Multi-select answers are stored joined with ', ' in the same map as
  /// single answers, so persistence and the profile display need no change.
  static const _separator = ', ';

  void answer(String questionId, String value) {
    state = {...state, questionId: value};
  }

  void toggleMulti(String questionId, String value, int max) {
    final current = state[questionId];
    final selected = current == null || current.isEmpty
        ? <String>[]
        : current.split(_separator);
    if (selected.contains(value)) {
      selected.remove(value);
    } else {
      if (selected.length >= max) return; // cap reached, ignore the tap
      selected.add(value);
    }
    final next = {...state};
    if (selected.isEmpty) {
      next.remove(questionId);
    } else {
      next[questionId] = selected.join(_separator);
    }
    state = next;
  }

  void clearAnswer(String questionId) {
    final next = {...state}..remove(questionId);
    state = next;
  }

  static List<String> splitMulti(String? answer) =>
      answer == null || answer.isEmpty ? const [] : answer.split(_separator);

  Future<void> persist() async {
    final answers = state;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(
        onboardingComplete: true,
        answers: answers,
        streak: p.streak == 0 ? 1 : p.streak,
      ),
    );
    await NotificationService.scheduleFromPrefs();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, Map<String, String>>(
      (ref) => OnboardingNotifier(),
    );

final onboardingCompleteProvider = StateProvider<bool>(
  (ref) => MirraBoxes.current.onboardingComplete,
);
