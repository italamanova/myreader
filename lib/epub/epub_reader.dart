import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class EpubReaderPage extends StatefulWidget {
  final String filePath;

  const EpubReaderPage({super.key, required this.filePath});

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  late final EpubController _epubController;

  @override
  void initState() {
    super.initState();
    debugPrint('EpubReaderPage: initState - opening ${widget.filePath}');
    _epubController = EpubController(
      document: EpubDocument.openFile(File(widget.filePath)),
    );
  }

  @override
  void dispose() {
    debugPrint('EpubReaderPage: dispose - disposing controller');
    _epubController.dispose();
    super.dispose();
  }

  void _translateWord(String word) {
    debugPrint('Translate requested for: "$word"');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Translation'),
        content: Text('Translated: $word'),
      ),
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EPUB Reader')),
      body: EpubView(
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          chapterDividerBuilder: (_) => const Divider(),
        ),
        controller: _epubController,
      ),
    );
  }
}