import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../shared/models/user_prefs.dart';

class OnboardingNotifier extends StateNotifier<Map<String, String>> {
  OnboardingNotifier() : super({...MirraBoxes.current.answers});

  void answer(String questionId, String value) {
    state = {...state, questionId: value};
  }

  Future<void> persist() async {
    final answers = state;
    await MirraBoxes.updatePrefs(
      (p) => UserPrefs(
        onboardingComplete: true,
        answers: answers,
        selectedTopics: p.selectedTopics,
        streak: p.streak == 0 ? 1 : p.streak,
        iconChoice: p.iconChoice,
        themeChoice: p.themeChoice,
      ),
    );
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, Map<String, String>>(
  (ref) => OnboardingNotifier(),
);

final onboardingCompleteProvider = StateProvider<bool>(
  (ref) => MirraBoxes.current.onboardingComplete,
);
