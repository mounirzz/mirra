import 'package:hive/hive.dart';

class HistoryEntry {
  HistoryEntry({required this.quoteId, DateTime? viewedAt})
      : viewedAt = viewedAt ?? DateTime.now();

  final String quoteId;
  final DateTime viewedAt;
}

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 4;

  @override
  HistoryEntry read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      quoteId: fields[0] as String,
      viewedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.quoteId)
      ..writeByte(1)
      ..write(obj.viewedAt);
  }
}
