import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'pdf_translate_and_highlight.dart';

Future<Directory> getOrCreatePdfFolder() async {
  final dir = await getApplicationDocumentsDirectory();
  final pdfDir = Directory('${dir.path}/MyPdfs');
  if (!await pdfDir.exists()) {
    await pdfDir.create(recursive: true);
  }
  return pdfDir;
}

Future<List<FileSystemEntity>> listPdfFiles() async {
  final folder = await getOrCreatePdfFolder();
  return folder
      .listSync()
      .where((f) => f.path.toLowerCase().endsWith('.pdf'))
      .toList();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<FileSystemEntity>> _pdfs;

  @override
  void initState() {
    super.initState();
    _pdfs = listPdfFiles();
  }

  Future<void> _importPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final pickedFile = File(result.files.single.path!);
    final folder = await getOrCreatePdfFolder();
    final newPath = '${folder.path}/${pickedFile.uri.pathSegments.last}';
    final newFile = File(newPath);

    if (await newFile.exists()) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('File already exists'),
          content: Text('A file named "${pickedFile.uri.pathSegments.last}" already exists in your library.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }


    await pickedFile.copy(newPath);

    setState(() {
      _pdfs = listPdfFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My PDFs')),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _pdfs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snapshot.data!;
          if (files.isEmpty) {
            return const Center(child: Text('No PDFs found in MyPdfs folder'));
          }
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, i) {
              final file = files[i] as File;
              final name = file.uri.pathSegments.last;
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(name),
                onTap: () async {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfTranslateAndHighlight(
                        apiKey: null,
                        file: file,
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete file'),
                        content: Text('Do you really want to delete "$name"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await file.delete();
                      setState(() {
                        _pdfs = listPdfFiles(); // refresh the list
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted "$name"')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importPdf,
        child: const Icon(Icons.add),
      ),
    );
  }
}
