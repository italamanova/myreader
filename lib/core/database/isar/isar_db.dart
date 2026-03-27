import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../features/words/data/models/word_entry.dart';

/// Singleton wrapper for Isar database
class IsarDb {
  static Isar? _instance;
  static bool _opening = false;

  /// Get or initialize the Isar database instance
  static Future<Isar> open() async {
    if (_instance != null) return _instance!;

    // Prevent concurrent opens
    if (_opening) {
      while (_instance == null) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return _instance!;
    }

    _opening = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _instance = await Isar.open(
        [WordEntrySchema],
        directory: dir.path,
        name: 'app_db',
      );
      return _instance!;
    } finally {
      _opening = false;
    }
  }

  /// Get the current instance (must be called after open())
  static Future<Isar> get instance async => await open();
}
