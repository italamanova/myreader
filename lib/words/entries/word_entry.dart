import 'package:isar/isar.dart';

part 'word_entry.g.dart';

@collection
class WordEntry {
  Id id = Isar.autoIncrement;

  late String wordNormalized;
  late String wordOriginal;

  String? translation;

  late String bookPath;
  late int pageNumber;

  // String? context;

  late DateTime createdAt;

  // int timesSeen = 0;
  // int timesCorrect = 0;
  // DateTime? lastReviewed;

  WordEntry();
}