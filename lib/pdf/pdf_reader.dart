import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../translation_service.dart';
import 'text_popup.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({super.key, this.apiKey, required this.filePath});

  final String? apiKey;
  final File filePath;

  @override
  State<PdfReaderPage> createState() =>
      _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  final _viewerKey = GlobalKey<SfPdfViewerState>();
  late final PdfViewerController _controller;
  late final TranslationService _translator;
  OverlayEntry? _popup;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    final apiKey = widget.apiKey ?? dotenv.env['DEEPL_API_KEY']!;
    _translator = DeepLTranslationService(apiKey);

    // Restore last page
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lastPage = await _loadLastPage();
      if (lastPage != null) {
        _controller.jumpToPage(lastPage);
      }
    });
  }

  @override
  void dispose() {
    _popup?.remove();
    _controller.dispose();
    super.dispose();
  }

  // Save & load last page position
  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage_${widget.filePath.path}', page);
  }

  Future<int?> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastPage_${widget.filePath.path}');
  }

  // Auto-save annotations
  Future<void> _autoSave() async {
    try {
      final bytes =
      await _controller.saveDocument(flattenOption: PdfFlattenOption.none);
      await widget.filePath.writeAsBytes(bytes, flush: true);
      debugPrint('Auto-saved to ${widget.filePath.path}');
    } catch (e) {
      debugPrint('Auto-save failed: $e');
    }
  }

  // Popup management
  void _hidePopup() {
    _popup?.remove();
    _popup = null;
  }

  void _showPopup(BuildContext context, PdfTextSelectionChangedDetails d) {
    final overlay = Overlay.of(context);
    final region = d.globalSelectedRegion!;
    _popup?.remove();

    _popup = OverlayEntry(
      builder: (_) => TextSelectionPopup(
        region: region,
        selectedText: d.selectedText ?? '',
        translator: _translator,
        controller: _controller,
        getSelectedTextLines: () =>
        _viewerKey.currentState?.getSelectedTextLines() ?? [],
        onClose: () {
          _controller.clearSelection();
          _hidePopup();
        },
      ),
    );

    overlay.insert(_popup!);
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Reader')),
      body: SfPdfViewer.file(
        widget.filePath,
        key: _viewerKey,
        controller: _controller,
        canShowTextSelectionMenu: false,
        onPageChanged: (d) => _saveLastPage(d.newPageNumber),
        onTextSelectionChanged: (d) {
          if (d.selectedText == null || d.globalSelectedRegion == null) {
            _hidePopup();
          } else {
            _showPopup(context, d);
          }
        },
        onAnnotationSelected: (details) async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete annotation?'),
              content: const Text('Do you want to remove this highlight?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            _controller.removeAnnotation(details);
          }
        },
        onAnnotationAdded: (_) => _autoSave(),
        onAnnotationRemoved: (_) => _autoSave(),
        onAnnotationEdited: (_) => _autoSave(),
      ),
    );
  }
}
