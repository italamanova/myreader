import 'package:isar_community/isar.dart';

part 'word_entry.g.dart';

/// Word entry model for Isar database
@collection
class WordEntry {
  Id id = Isar.autoIncrement;

  late String wordNormalized;
  late String wordOriginal;

  String? translation;

  late String bookPath;
  late int pageNumber;

  late DateTime createdAt;

  int timesSeen = 0;
  int timesCorrect = 0;

  WordEntry();
}

