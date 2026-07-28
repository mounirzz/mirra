// End-to-end walk of the streak hub (🔥) and the Preferences flow: every
// row must open its screen, and Muted content must actually mute/unmute.
//
// Run: flutter test integration_test/menus_test.dart -d <simulator>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mirra/core/storage/hive_boxes.dart';
import 'package:mirra/main.dart' as app;

/// The feed has infinite animations (flame badge, swipe hint), so
/// pumpAndSettle would never settle — pump fixed frames instead.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Taps the first back/close affordance found on the current screen.
Future<void> goBack(WidgetTester tester) async {
  final back = find.byIcon(Icons.arrow_back_ios_new_rounded);
  final close = find.byIcon(Icons.close_rounded);
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back.first);
  } else {
    await tester.tap(close.first);
  }
  await settle(tester);
}

Future<void> openAndReturn(
  WidgetTester tester,
  String rowLabel,
  String expectedOnScreen,
) async {
  await tester.tap(find.text(rowLabel).first);
  await settle(tester);
  expect(
    find.textContaining(expectedOnScreen),
    findsWidgets,
    reason: '"$rowLabel" should open a screen containing "$expectedOnScreen"',
  );
  await goBack(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('streak hub and preferences all work', (tester) async {
    // Land straight on the feed: onboarding runs native iOS dialogs
    // (notification permission, app-icon change alert) that a widget test
    // cannot dismiss. Seeding it complete keeps this test focused on the hub
    // and Preferences flows it's meant to verify.
    await MirraBoxes.init();
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(onboardingComplete: true, seenSwipeHint: true),
    );

    await app.main();
    await settle(tester);
    await tester.pump(const Duration(seconds: 3)); // streak celebration
    await settle(tester);

    // Reach the feed whatever the launch state (welcome / onboarding /
    // paywall) so the test is independent of persisted progress.
    for (var guard = 0; guard < 40; guard++) {
      if (find.text('🔥').evaluate().isNotEmpty) break;

      // Welcome → start onboarding.
      final swipeUp = find.text('Swipe up');
      if (swipeUp.evaluate().isNotEmpty) {
        await tester.tap(swipeUp);
        await settle(tester);
        continue;
      }
      // Paywall → close.
      final close = find.byIcon(Icons.close_rounded);
      if (close.evaluate().isNotEmpty &&
          find.textContaining('Mirra+').evaluate().isNotEmpty) {
        await tester.tap(close.first);
        await settle(tester);
        continue;
      }
      // Onboarding → pick first chip, then Continue / Start Mirra.
      final cont = find.text('Continue');
      final start = find.text('Start Mirra');
      final chips = find.byType(GestureDetector);
      if (cont.evaluate().isNotEmpty || start.evaluate().isNotEmpty) {
        if (chips.evaluate().length > 2) {
          await tester.tap(chips.at(1));
          await settle(tester);
        }
        await tester.tap(start.evaluate().isNotEmpty ? start : cont);
        await settle(tester);
        continue;
      }
      await settle(tester);
    }

    // ── Streak hub ─────────────────────────────────────────────────────
    expect(find.text('🔥'), findsWidgets, reason: 'flame badge on feed');
    await tester.tap(find.text('🔥').first);
    await settle(tester);
    expect(find.text('Your streak'), findsOneWidget);
    expect(find.text('Customize the app'), findsOneWidget);

    await openAndReturn(tester, 'My favorites', 'avorites');
    await openAndReturn(tester, 'My own quotes', 'affirmation');
    await openAndReturn(tester, 'My profile', 'Profile');

    // "Customize the app" cards each open their screen.
    await openAndReturn(tester, 'Topics you follow', 'Bundles');
    await openAndReturn(tester, 'App icon', 'icon');

    // Themes opens the catalog.
    await tester.tap(find.text('Themes').first);
    await settle(tester);
    expect(find.text('For you'), findsWidgets);
    await goBack(tester);

    // Settings (top right) → Preferences menu.
    await tester.tap(find.text('Settings'));
    await settle(tester);
    expect(find.text('Preferences'), findsWidgets);

    // ── Preferences rows ───────────────────────────────────────────────
    // Non-premium: the subscription row opens the upgrade pitch (free trial).
    await openAndReturn(tester, 'Manage subscription', 'free trial');
    await openAndReturn(tester, 'Content preferences', 'categories');
    await openAndReturn(tester, 'Gender identity', 'personalize');
    await openAndReturn(tester, 'Language', 'English');
    await openAndReturn(tester, 'Sound', 'THEME SOUND');
    await openAndReturn(tester, 'Reminders', 'Daily reminders');

    // Name: type + Save (returns automatically).
    await tester.tap(find.text('Name').first);
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Yassine');
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('Yassine'), findsWidgets, reason: 'saved name shown');

    // ── Muted content: mute then unmute for real ───────────────────────
    await tester.tap(find.text('Muted content'));
    await settle(tester);
    expect(find.textContaining('muted'), findsWidgets);
    await tester.tap(find.text('Add muted content'));
    await settle(tester);
    await tester.tap(find.text('Workout').last);
    await settle(tester);
    expect(find.text('Workout'), findsOneWidget, reason: 'Workout now muted');
    await tester.tap(find.text('Unmute'));
    await settle(tester);
    expect(find.textContaining('haven’t muted'), findsOneWidget);
    await goBack(tester);

    // App theme row (near the bottom of the list) opens the catalog.
    await tester.scrollUntilVisible(
      find.text('App theme'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('App theme'));
    await settle(tester);
    expect(find.text('For you'), findsWidgets);
    await goBack(tester);
  });
}
