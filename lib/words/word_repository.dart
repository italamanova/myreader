import 'package:isar_community/isar.dart';
import 'entries/word_entry.dart';
import 'isar_db.dart';

class WordsRepository {
  Future<Isar> get _db async => IsarDb.open();

  String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  Future<WordEntry> addWord({
    required String word,
    String? translation,
    required String bookPath,
    required int pageNumber,
    String? context,
  }) async {
    final db = await _db;
    final normalized = _normalize(word);

    final existing = await db.wordEntrys
        .filter()
        .wordNormalizedEqualTo(normalized)
        .bookPathEqualTo(bookPath)
        .pageNumberEqualTo(pageNumber)
        .findFirst();

    final entry = WordEntry()
      ..wordOriginal = word.trim()
      ..wordNormalized = normalized
      ..translation = translation
      ..bookPath = bookPath
      ..pageNumber = pageNumber
      ..createdAt = DateTime.now();

    await db.writeTxn(() async {
      await db.wordEntrys.put(entry);
    });

    return entry;
  }

  Stream<List<WordEntry>> watchWordsForBook(String bookPath) async* {
    final db = await _db;

    yield* db.wordEntrys
        .filter()
        .bookPathEqualTo(bookPath)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Stream<List<WordEntry>> watchAllWords() async* {
    final db = await _db;
    yield* db.wordEntrys.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Future<void> deleteWord(Id id) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.wordEntrys.delete(id);
    });
  }
}
