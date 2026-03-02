import 'package:isar/isar.dart';

import 'isar_db.dart';
import 'entries/word_entry.dart';

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

    // if exists - show message that this word exists

    // if (existing != null) {
    //   // CHANGED: update translation/context if newly provided
    //   return await db.writeTxn(() async {
    //     if (translation != null && (existing.translation == null || existing.translation!.isEmpty)) {
    //       existing.translation = translation;
    //     }
    //     if (context != null && (existing.context == null || existing.context!.isEmpty)) {
    //       existing.context = context;
    //     }
    //     await db.wordEntrys.put(existing);
    //     return existing;
    //   });
    // }

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
    yield* db.wordEntrys.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Future<void> deleteWord(Id id) async {
    final db = await _db;
    await db.writeTxn(() async {
      await db.wordEntrys.delete(id);
    });
  }

  // Future<void> markReviewed({
  //   required Id id,
  //   required bool correct,
  // }) async {
  //   final db = await _db;
  //   final entry = await db.wordEntrys.get(id);
  //   if (entry == null) return;
  //
  //   await db.writeTxn(() async {
  //     entry.timesSeen += 1;
  //     if (correct) entry.timesCorrect += 1;
  //     entry.lastReviewed = DateTime.now();
  //     await db.wordEntrys.put(entry);
  //   });
  // }
}