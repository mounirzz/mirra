import 'package:hive/hive.dart';

class UserPrefs {
  UserPrefs({
    this.onboardingComplete = false,
    this.answers = const {},
    this.selectedTopics = const [],
    this.streak = 0,
    this.iconChoice = 'i2',
    this.themeChoice = 'color:cabin',
    this.customPhotoPath,
    this.lastOpenDate,
    this.seenSwipeHint = false,
    this.notificationsEnabled = true,
    this.isPremium = false,
    this.languageCode = 'en',
    this.displayName,
    this.themeVolume = 0.5,
    this.mutedCategories = const [],
    this.premiumPlan,
    this.premiumSince,
  });

  bool onboardingComplete;
  Map<String, String> answers;
  List<String> selectedTopics;
  int streak;
  String iconChoice;
  String themeChoice;
  String? customPhotoPath;

  /// Last day the app was opened, stored as 'yyyy-MM-dd'. Drives the streak.
  String? lastOpenDate;

  /// Whether the one-time "swipe up" hint on the feed has been shown.
  bool seenSwipeHint;

  /// Master switch for the daily reminder notifications.
  bool notificationsEnabled;

  /// Whether the user owns Mirra+ (subscription or lifetime).
  bool isPremium;

  /// UI language ('en' or 'fr').
  String languageCode;

  /// First name used to personalize content (Preferences > Name).
  String? displayName;

  /// Theme sound volume, 0..1 (Preferences > Sound).
  double themeVolume;

  /// Category ids hidden from the feed (Preferences > Muted content).
  List<String> mutedCategories;

  /// Purchased Mirra+ plan name and ISO date, for Manage subscription.
  String? premiumPlan;
  String? premiumSince;

  UserPrefs copyWith({
    bool? onboardingComplete,
    Map<String, String>? answers,
    List<String>? selectedTopics,
    int? streak,
    String? iconChoice,
    String? themeChoice,
    String? customPhotoPath,
    String? lastOpenDate,
    bool? seenSwipeHint,
    bool? notificationsEnabled,
    bool? isPremium,
    String? languageCode,
    String? displayName,
    double? themeVolume,
    List<String>? mutedCategories,
    String? premiumPlan,
    String? premiumSince,
  }) {
    return UserPrefs(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      answers: answers ?? this.answers,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      streak: streak ?? this.streak,
      iconChoice: iconChoice ?? this.iconChoice,
      themeChoice: themeChoice ?? this.themeChoice,
      customPhotoPath: customPhotoPath ?? this.customPhotoPath,
      lastOpenDate: lastOpenDate ?? this.lastOpenDate,
      seenSwipeHint: seenSwipeHint ?? this.seenSwipeHint,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isPremium: isPremium ?? this.isPremium,
      languageCode: languageCode ?? this.languageCode,
      displayName: displayName ?? this.displayName,
      themeVolume: themeVolume ?? this.themeVolume,
      mutedCategories: mutedCategories ?? this.mutedCategories,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumSince: premiumSince ?? this.premiumSince,
    );
  }
}

class UserPrefsAdapter extends TypeAdapter<UserPrefs> {
  @override
  final int typeId = 2;

  @override
  UserPrefs read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return UserPrefs(
      onboardingComplete: fields[0] as bool? ?? false,
      answers: (fields[1] as Map?)?.cast<String, String>() ?? const {},
      selectedTopics: (fields[2] as List?)?.cast<String>() ?? const [],
      streak: fields[3] as int? ?? 0,
      iconChoice: fields[4] as String? ?? 'i2',
      themeChoice: fields[5] as String? ?? 'color:cabin',
      customPhotoPath: fields[6] as String?,
      lastOpenDate: fields[7] as String?,
      seenSwipeHint: fields[8] as bool? ?? false,
      notificationsEnabled: fields[9] as bool? ?? true,
      isPremium: fields[10] as bool? ?? false,
      languageCode: fields[11] as String? ?? 'en',
      displayName: fields[12] as String?,
      themeVolume: (fields[13] as num?)?.toDouble() ?? 0.5,
      mutedCategories: (fields[14] as List?)?.cast<String>() ?? const [],
      premiumPlan: fields[15] as String?,
      premiumSince: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPrefs obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.onboardingComplete)
      ..writeByte(1)
      ..write(obj.answers)
      ..writeByte(2)
      ..write(obj.selectedTopics)
      ..writeByte(3)
      ..write(obj.streak)
      ..writeByte(4)
      ..write(obj.iconChoice)
      ..writeByte(5)
      ..write(obj.themeChoice)
      ..writeByte(6)
      ..write(obj.customPhotoPath)
      ..writeByte(7)
      ..write(obj.lastOpenDate)
      ..writeByte(8)
      ..write(obj.seenSwipeHint)
      ..writeByte(9)
      ..write(obj.notificationsEnabled)
      ..writeByte(10)
      ..write(obj.isPremium)
      ..writeByte(11)
      ..write(obj.languageCode)
      ..writeByte(12)
      ..write(obj.displayName)
      ..writeByte(13)
      ..write(obj.themeVolume)
      ..writeByte(14)
      ..write(obj.mutedCategories)
      ..writeByte(15)
      ..write(obj.premiumPlan)
      ..writeByte(16)
      ..write(obj.premiumSince);
  }
}
