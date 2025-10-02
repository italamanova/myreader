import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myreader/text_popup.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'translation_service.dart';

class PdfTranslateAndHighlight extends StatefulWidget {
  const PdfTranslateAndHighlight({super.key, this.apiKey, required this.file});

  final String? apiKey;
  final File file;

  @override
  State<PdfTranslateAndHighlight> createState() =>
      _PdfTranslateAndHighlightState();
}

class _PdfTranslateAndHighlightState extends State<PdfTranslateAndHighlight> {
  final _viewerKey = GlobalKey<SfPdfViewerState>();
  late final PdfViewerController _controller;
  late final TranslationService _translator;

  OverlayEntry? _popup;
  String _chosenLang = 'uk'; // default target language
  String? _lastTranslation;
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    final apiKey = widget.apiKey ?? dotenv.env['DEEPL_API_KEY']!;
    _translator = DeepLTranslationService(apiKey);
    _controller = PdfViewerController();
  }

  @override
  void dispose() {
    _popup?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _hidePopup() {
    _popup?.remove();
    _popup = null;
    _lastTranslation = null;
  }

  Future<void> _translateSelectedText(
    BuildContext context,
    PdfTextSelectionChangedDetails d,
  ) async {
    setState(() {
      _translating = true;
      _lastTranslation = null;
    });
    try {
      final translated = await _translator.translate(
        text: d.selectedText!.trim(),
        targetLang: _chosenLang,
      );
      setState(() {
        _lastTranslation = translated;
        print(translated);
      });
      if (_popup != null) {
        _popup!.remove();
        _popup = null;
        _showPopup(context, d);
      }
    } catch (e) {
      setState(() {
        _lastTranslation = 'Translation failed: $e';
        print(e);
      });
    } finally {
      setState(() => _translating = false);
    }
  }

  void _showPopup(BuildContext context, PdfTextSelectionChangedDetails d) {
    final overlay = Overlay.of(context);
    final region = d.globalSelectedRegion!;

    _popup?.remove();
    _popup = OverlayEntry(
      builder: (_) => TextSelectionPopup(
        region: region,
        selectedText: d.selectedText,
        translation: _lastTranslation,
        translating: _translating,
        chosenLang: _chosenLang,
        onLangChanged: (lang) => setState(() => _chosenLang = lang),
        onTranslate: () => _translateSelectedText(context, d),
        onClose: () {
          _controller.clearSelection();
          _hidePopup();
        },
        onCopy: () {
          Clipboard.setData(ClipboardData(text: d.selectedText ?? ''));
        },
        onHighlight: (color) {
          final lines = _viewerKey.currentState?.getSelectedTextLines();
          if (lines != null && lines.isNotEmpty) {
            final ann = HighlightAnnotation(textBoundsCollection: lines)
              ..color = color
              ..opacity = 1.0;
            _controller.addAnnotation(ann);
          }
        },
      ),
    );
    overlay.insert(_popup!);
  }

  Future<void> _autoSave() async {
    try {
      final bytes = await _controller.saveDocument(flattenOption: PdfFlattenOption.none);
      await widget.file.writeAsBytes(bytes, flush: true);
      print('Auto-saved annotations to ${widget.file.path}');
    } catch (e) {
      print('Auto-save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book reader'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.save),
          //   onPressed: _savePdfWithAnnotations,
          // ),
        ],
      ),
      body: SfPdfViewer.memory(
        widget.file.readAsBytesSync(),
        key: _viewerKey,
        controller: _controller,
        canShowTextSelectionMenu: false, // we supply our own popup
        onTextSelectionChanged: (details) {
          if (details.selectedText == null ||
              details.globalSelectedRegion == null) {
            _hidePopup();
          } else {
            _showPopup(context, details);
          }
        },
        onAnnotationAdded: (_) => _autoSave(),
        onAnnotationRemoved: (_) => _autoSave(),
        onAnnotationEdited: (_) => _autoSave(),
      ),
    );
  }
}
