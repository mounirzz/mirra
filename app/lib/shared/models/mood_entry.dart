import 'package:hive/hive.dart';

class MoodEntry {
  MoodEntry({required this.score, DateTime? date})
      : date = date ?? DateTime.now();

  /// 0..4 (matches the 5-point onboarding mood scale)
  final int score;
  final DateTime date;

  String get label {
    const labels = ['Anxious', 'Flat', 'Okay', 'Good', 'Glowing'];
    return labels[score.clamp(0, 4)];
  }
}

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 5;

  @override
  MoodEntry read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      score: fields[0] as int,
      date: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.date);
  }
}
