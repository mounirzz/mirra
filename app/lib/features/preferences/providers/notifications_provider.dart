import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/hive_boxes.dart';

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  NotificationsEnabledNotifier()
    : super(MirraBoxes.current.notificationsEnabled);

  Future<void> set(bool enabled) async {
    state = enabled;
    await MirraBoxes.updatePrefs(
      (p) => p.copyWith(notificationsEnabled: enabled),
    );
    // Re-runs the scheduler, which cancels everything when disabled.
    await NotificationService.scheduleFromPrefs();
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>(
      (ref) => NotificationsEnabledNotifier(),
    );
