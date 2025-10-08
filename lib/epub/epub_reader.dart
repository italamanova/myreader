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
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();

    // Initialize controller with file
    _epubController = EpubController(
      document: EpubDocument.openFile(File(widget.filePath)),
    );
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }

  void _translateWord(String word) async {
    // Here you can call your translation logic, API, etc.
    // For demo, just show a dialog with the "translation"
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Translation"),
        content: Text("Translated: $word"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EPUB Reader")),
      // body: EpubView(
      //   controller: _epubController,
      //   onDocumentLoaded: (_) {
      //     debugPrint("EPUB loaded");
      //   },
      //   onExternalLinkPressed: (url) {
      //     debugPrint("External link: $url");
      //   },
      //   // Capture text taps
      //   builders: EpubViewBuilders<DefaultBuilderOptions>(
      //     options: const DefaultBuilderOptions(),
      //     chapterContentBuilder: (context, chapter, textStyle) {
      //       return SelectableText(
      //         chapter.HtmlContent ?? '',
      //         style: textStyle,
      //         onSelectionChanged: (selection, cause) {
      //           if (selection != null && selection.text.isNotEmpty) {
      //             // When user selects a word, translate it
      //             _translateWord(selection.text);
      //           }
      //         },
      //       );
      //     },
      //   ),
      // ),
    );
  }
}
