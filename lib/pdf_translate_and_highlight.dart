import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myreader/pdf_popup.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'translation_service.dart';

class PdfTranslateAndHighlight extends StatefulWidget {
  const PdfTranslateAndHighlight({
    super.key,
    this.apiKey,
    required this.file,
  });

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

  Uint8List? _bytes;
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
    _bytes = widget.file.readAsBytesSync();
  }

  @override
  void dispose() {
    _popup?.remove();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (res != null) setState(() => _bytes = res.files.single.bytes);
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
      builder: (_) => PdfSelectionPopup(
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
              ..opacity = 0.7;
            _controller.addAnnotation(ann);
          }
        },
      ),
    );
    overlay.insert(_popup!);
  }

  Future<void> _savePdfWithAnnotations() async {
    try {
      // 1. Ask viewer to give us the current doc with annotations
      final annotatedBytes = await _controller.saveDocument(
        flattenOption: PdfFlattenOption.none,
      );

      // 2. Overwrite the same file in the app’s folder
      await widget.file.writeAsBytes(annotatedBytes, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annotations saved to ${widget.file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save annotations: $e')),
        );
      }
    }
  }
  // Future<void> _savePdfWithAnnotations() async {
  //   if (_bytes == null) return;
  //
  //   try {
  //     // Grab the whole PDF *including the annotations currently in the viewer*
  //     final savedBytes = await _controller.saveDocument(
  //       // Only affects form fields; annotations remain editable either way.
  //       flattenOption: PdfFlattenOption.none,
  //     );
  //
  //     final dir = await getApplicationDocumentsDirectory();
  //     final outDir = Directory('${dir.path}/AnnotatedPDFs');
  //     await outDir.create(recursive: true);
  //
  //     final filePath =
  //         '${outDir.path}/annotated_${DateTime.now().toIso8601String().replaceAll(":", "-")}.pdf';
  //     await File(filePath).writeAsBytes(savedBytes, flush: true);
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Saved annotated PDF to $filePath')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to save PDF: $e')),
  //       );
  //     }
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book reader'),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open), onPressed: _pickPdf),
          IconButton(icon: const Icon(Icons.save), onPressed: _savePdfWithAnnotations),
        ],
      ),
      body:
          SfPdfViewer.memory(
              _bytes!,
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
            ),
    );
  }
}
