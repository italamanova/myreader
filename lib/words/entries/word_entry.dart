import 'package:isar_community/isar.dart';
part 'word_entry.g.dart';

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
