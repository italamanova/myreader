import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../constants/app_constants.dart';

/// Service for managing local book storage
class LocalBookStorageService {
  /// Get or create the books folder
  static Future<Directory> getOrCreateBooksFolder() async {
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/${AppConstants.booksFolder}');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir;
  }

  /// List all book files in the books folder
  static Future<List<FileSystemEntity>> listBookFiles() async {
    final dir = await getOrCreateBooksFolder();
    if (!await dir.exists()) return <FileSystemEntity>[];

    final all = await dir.list().toList();
    return all.where((f) {
      final name = f.path.toLowerCase();
      return AppConstants.supportedFormats
          .any((ext) => name.endsWith('.$ext'));
    }).toList();
  }

  /// Delete a book file
  static Future<void> deleteBook(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  /// Save a book file
  static Future<String> saveBook(File file, String fileName) async {
    try {
      final destDir = await getOrCreateBooksFolder();
      final destPath = '${destDir.path}/$fileName';
      file.copy(destPath);
      return destPath;
    } catch (e) {
      throw Exception('Failed to save book: $e');
    }
  }
}
