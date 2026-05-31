import 'package:hive/hive.dart';

enum ThemeModePref { system, light, dark }

class UserPrefs {
  UserPrefs({
    this.onboardingComplete = false,
    this.answers = const {},
    this.selectedTopics = const [],
    this.streak = 0,
    this.iconChoice = 'i2',
    this.themeChoice = 'cabin',
    this.themeMode = ThemeModePref.light,
    this.language = 'en',
    this.quoteFontSize = 34.0,
  });

  bool onboardingComplete;
  Map<String, String> answers;
  List<String> selectedTopics;
  int streak;
  String iconChoice;
  String themeChoice;
  ThemeModePref themeMode;
  String language;
  double quoteFontSize;
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
      themeChoice: fields[5] as String? ?? 'cabin',
      themeMode: ThemeModePref.values[
          (fields[6] as int? ?? ThemeModePref.light.index)
              .clamp(0, ThemeModePref.values.length - 1)],
      language: fields[7] as String? ?? 'en',
      quoteFontSize: fields[8] as double? ?? 34.0,
    );
  }

  @override
  void write(BinaryWriter writer, UserPrefs obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.themeMode.index)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.quoteFontSize);
  }
}
