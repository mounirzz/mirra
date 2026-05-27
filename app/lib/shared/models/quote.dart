import 'package:hive/hive.dart';

class QuoteCategory {
  const QuoteCategory._(this.id, this.label);

  final String id;
  final String label;

  static const motivation = QuoteCategory._('motivation', 'Motivation');
  static const confidence = QuoteCategory._('confidence', 'Self-confidence');
  static const productivity = QuoteCategory._('productivity', 'Productivity');
  static const workout = QuoteCategory._('workout', 'Workout');
  static const love = QuoteCategory._('love', 'Love');
  static const healing = QuoteCategory._('healing', 'Breakup healing');
  static const stress = QuoteCategory._('stress', 'Stress relief');
  static const mindfulness = QuoteCategory._('mindfulness', 'Mindfulness');
  static const success = QuoteCategory._('success', 'Success');
  static const business = QuoteCategory._('business', 'Business & money');
  static const family = QuoteCategory._('family', 'Family');
  static const life = QuoteCategory._('life', 'Life lessons');
  static const gratitude = QuoteCategory._('gratitude', 'Gratitude');
  static const women = QuoteCategory._('women', 'Women empowerment');
  static const philosophy = QuoteCategory._('philosophy', 'Philosophy');
  static const sports = QuoteCategory._('sports', 'Sports');
  static const happiness = QuoteCategory._('happiness', 'Happiness');
  static const faith = QuoteCategory._('faith', 'Faith & spirituality');

  static const all = <QuoteCategory>[
    motivation,
    confidence,
    productivity,
    workout,
    love,
    healing,
    stress,
    mindfulness,
    success,
    business,
    family,
    life,
    gratitude,
    women,
    philosophy,
    sports,
    happiness,
    faith,
  ];

  static QuoteCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => motivation);
}

class Quote {
  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.categoryId,
  });

  final String id;
  final String text;
  final String author;
  final String categoryId;

  QuoteCategory get category => QuoteCategory.byId(categoryId);
}

class QuoteAdapter extends TypeAdapter<Quote> {
  @override
  final int typeId = 1;

  @override
  Quote read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return Quote(
      id: fields[0] as String,
      text: fields[1] as String,
      author: fields[2] as String,
      categoryId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Quote obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.categoryId);
  }
}
