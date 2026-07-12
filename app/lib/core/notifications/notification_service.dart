import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/seed_quotes.dart';
import '../storage/hive_boxes.dart';

/// Schedules the daily affirmation reminders promised by the onboarding
/// (time + frequency questions). Everything is local — no server involved.
class NotificationService {
  const NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Hour of the day each onboarding answer anchors to.
  static const _anchorHours = <String, int>{
    'Morning': 8,
    'Midday': 12,
    'Evening': 19,
    'Night': 22,
  };

  static const _frequencies = <String, int>{
    'Once a day': 1,
    '3 times': 3,
    '11 times': 11,
  };

  static Future<void> init() async {
    tz.initializeTimeZones();
    final localZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localZone));

    // Permissions are NOT requested here: asking at launch, before the user
    // understands the app, tanks the acceptance rate. [requestPermission] is
    // called from the onboarding right after they pick a reminder time.
    await _plugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Shows the iOS permission prompt. Called at the moment of maximum
  /// intent: right after the user chooses when they want their reminders.
  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// (Re)programs every reminder from the saved onboarding answers. Called at
  /// each app launch and whenever the user changes time/frequency in
  /// Preferences, so notification contents also rotate regularly.
  static Future<void> scheduleFromPrefs() async {
    final prefs = MirraBoxes.current;
    final answers = prefs.answers;
    if (!prefs.onboardingComplete) return;

    await _plugin.cancelAll();
    if (!prefs.notificationsEnabled) return; // master switch is off

    final anchor = _anchorHours[answers['time']] ?? 8;
    final count = _frequencies[answers['frequency']] ?? 1;
    final slots = _buildSlots(anchor, count);

    final random = Random();
    final quotes = List.of(kSeedQuotes)..shuffle(random);

    for (var i = 0; i < slots.length; i++) {
      final quote = quotes[i % quotes.length];
      await _plugin.zonedSchedule(
        i,
        'Mirra',
        '${quote.text} — ${quote.author}',
        _nextInstanceOf(slots[i].$1, slots[i].$2),
        const NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            'mirra_daily',
            'Daily affirmations',
            channelDescription: 'Your scheduled affirmation reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  /// One slot per notification as (hour, minute). A single reminder lands
  /// exactly on the chosen anchor; several are spread through the waking day
  /// (08:00–22:00) so 3x/11x don't all pile onto one moment.
  static List<(int, int)> _buildSlots(int anchor, int count) {
    if (count <= 1) return [(anchor, 0)];
    const startMinutes = 8 * 60;
    const endMinutes = 22 * 60;
    final step = (endMinutes - startMinutes) ~/ (count - 1);
    return [
      for (var i = 0; i < count; i++)
        ((startMinutes + i * step) ~/ 60, (startMinutes + i * step) % 60),
    ];
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
