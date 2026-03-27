import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/local_book_storage_service.dart';
import '../../../reader/presentation/pages/epub_reader_page.dart';
import '../../../reader/presentation/pages/pdf_reader_page.dart';
import '../../../words/presentation/pages/word_cards_page.dart';

/// Home page displaying the library of books
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<FileSystemEntity>> _books;

  @override
  void initState() {
    super.initState();
    _books = LocalBookStorageService.listBookFiles();
  }

  void _refresh() {
    setState(() {
      _books = LocalBookStorageService.listBookFiles();
    });
  }

  Future<void> _pickAndSave() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedFormats,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text('Importing book...'),
        content: SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      await LocalBookStorageService.saveBook(file.name, bytes);
      if (!mounted) return;
      Navigator.pop(context);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  void _openFile(FileSystemEntity entity) {
    final path = entity.path;
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfReaderPage(filePath: File(path), apiKey: null),
        ),
      );
    } else if (lower.endsWith('.epub')) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EpubReaderPage(filePath: path)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WordCardsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.style_outlined),
              label: const Text('Review'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _books,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snapshot.data!;
          if (files.isEmpty) {
            return const Center(
              child: Text('No books yet. Tap + to add a PDF or EPUB.'),
            );
          }
          return ListView.separated(
            itemCount: files.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final f = files[index];
              final name = f.path.split(Platform.pathSeparator).last;
              final isPdf = name.toLowerCase().endsWith('.pdf');

              return ListTile(
                leading: Icon(isPdf ? Icons.picture_as_pdf : Icons.menu_book),
                title: Text(name),
                subtitle: Text(f.path),
                onTap: () => _openFile(f),
                trailing: IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    try {
                      await LocalBookStorageService.deleteBook(f.path);
                      if (!mounted) return;
                      _refresh();
                    } catch (_) {}
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndSave,
        child: const Icon(Icons.add),
      ),
    );
  }
}


