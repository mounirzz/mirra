import 'package:hive/hive.dart';

class Collection {
  Collection({
    required this.id,
    required this.name,
    List<String>? quoteIds,
    DateTime? createdAt,
  })  : quoteIds = quoteIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final List<String> quoteIds;
  final DateTime createdAt;

  Collection copyWith({String? name, List<String>? quoteIds}) {
    return Collection(
      id: id,
      name: name ?? this.name,
      quoteIds: quoteIds ?? this.quoteIds,
      createdAt: createdAt,
    );
  }
}

class CollectionAdapter extends TypeAdapter<Collection> {
  @override
  final int typeId = 3;

  @override
  Collection read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return Collection(
      id: fields[0] as String,
      name: fields[1] as String,
      quoteIds: (fields[2] as List?)?.cast<String>() ?? const [],
      createdAt: fields[3] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, Collection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quoteIds)
      ..writeByte(3)
      ..write(obj.createdAt);
  }
}
