import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';

/// Current daily streak, sourced from persisted [UserPrefs].
final streakProvider = Provider<int>((ref) => MirraBoxes.current.streak);
