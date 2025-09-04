import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, int> _lastPages = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open a PDF')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf, size: 72),
              const SizedBox(height: 16),
              const Text('Pick a .pdf file from your computer/device',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.folder_open),
                label: const Text('Choose PDF'),
                onPressed: _openPicker,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final name = file.name;
    final bytes = file.bytes;

    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read file bytes.')),
      );
      return;
    }

    final lastPage = _lastPages[name] ?? 1;

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          fileName: name,
          data: bytes,
          initialPage: lastPage,
          onPageChanged: (page) => _lastPages[name] = page,
        ),
      ),
    );
  }
}

class ReaderScreen extends StatefulWidget {
  final String fileName;
  final Uint8List data;
  final int initialPage;
  final ValueChanged<int> onPageChanged;
  const ReaderScreen({
    super.key,
    required this.fileName,
    required this.data,
    required this.initialPage,
    required this.onPageChanged,
  });
  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final PdfController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: PdfDocument.openData(widget.data),
      initialPage: widget.initialPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            tooltip: 'Prev',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _controller.previousPage(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
            ),
          ),
          IconButton(
            tooltip: 'Next',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _controller.nextPage(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeIn,
            ),
          ),
          const SizedBox(width: 8),
          Center(
              child: PdfPageNumber(
                controller: _controller,
                builder: (_, loadingState, page, pagesCount) => Text(
                  loadingState == PdfLoadingState.success
                      ? '$page/${pagesCount ?? 0}'
                      : '…',
                ),
              )
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: PdfView(
        controller: _controller,
        // Custom renderer options per latest pdfx docs
        renderer: (PdfPage page) => page.render(
          width: page.width * 4,
          height: page.height * 4,
          format: PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
        ),
        onPageChanged: (page) => widget.onPageChanged(page),
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
      ),
    );
  }
}