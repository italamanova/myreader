import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'entries/word_entry.dart';

class IsarDb {
  static Isar? _instance;

  static Future<Isar> open() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [WordEntrySchema],
      directory: dir.path,
      name: 'app_db',
    );
    return _instance!;
  }
}
