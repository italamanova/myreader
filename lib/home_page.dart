import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'pdf/pdf_reader.dart';
import 'epub/epub_reader.dart';

Future<Directory> getOrCreateBooksFolder() async {
  final dir = await getApplicationDocumentsDirectory();
  final Directory booksDir;
  booksDir = Directory('${dir.path}/MyBooks');
  if (!await booksDir.exists()) {
    await booksDir.create(recursive: true);
  }
  return booksDir;
}


Future<List<FileSystemEntity>> listBookFiles() async {
  final dir = await getOrCreateBooksFolder();
  if (!await dir.exists()) return <FileSystemEntity>[];
  final all = await dir.list().toList();
  return all.where((f) {
    final name = f.path.toLowerCase();
    return name.endsWith('.pdf') || name.endsWith('.epub');
  }).toList();
}
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
    _books = listBookFiles();
  }

  void _refresh()  {
    setState(() { _books = listBookFiles(); });
  }

  Future<void> _pickAndSave() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'epub'], 
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return;

    final destDir = await getOrCreateBooksFolder(); 
    final destPath = '${destDir.path}/${file.name}';
    final out = File(destPath);
    await out.writeAsBytes(bytes, flush: true);

    if (!mounted) return;
    _refresh();
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
        MaterialPageRoute(
          builder: (_) => EpubReaderPage(filePath: path), 
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books (PDF + EPUB)'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                      await File(f.path).delete();
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
