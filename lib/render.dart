import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'translation_service.dart';

class PdfTranslateAndHighlight extends StatefulWidget {
  const PdfTranslateAndHighlight({super.key, this.apiKey});
  final String? apiKey;
  @override
  State<PdfTranslateAndHighlight> createState() => _PdfTranslateAndHighlightState();
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

  Future<void> _translateSelectedText(BuildContext context, PdfTextSelectionChangedDetails d) async {
    setState(() {
      _translating = true;
      _lastTranslation = null;
    });
    try {
      final translated = await _translator.translate(text: d.selectedText!.trim(), targetLang: _chosenLang);
      setState(() {
        _lastTranslation = translated;
        print(translated);   // 👈 this prints to your debug console
      });
      if (_popup != null) {
        _popup!.remove();
        _popup = null;
        _showPopup(context, d);
      }
    } catch (e) {
      // setState(() => _lastTranslation = 'Translation failed: $e');
      setState(() {
        _lastTranslation = 'Translation failed: $e';
        print(e);   // 👈 this prints to your debug console
      });
    } finally {
      setState(() => _translating = false);
    }
  }

  void _showPopup(BuildContext context, PdfTextSelectionChangedDetails d) {
    final overlay = Overlay.of(context);
    final region = d.globalSelectedRegion!;
    const width = 300.0;

    _popup?.remove();
    _popup = OverlayEntry(
      builder: (_) {
        final theme = Theme.of(context);
        return Positioned(
          left: (region.left).clamp(8, MediaQuery.of(context).size.width - width - 8),
          top: (region.top - 140).clamp(8, MediaQuery.of(context).size.height - 160),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: width),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Color row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final c in [Colors.yellow, Colors.cyan, Colors.pinkAccent, Colors.lime])
                          InkWell(
                            child: CircleAvatar(radius: 12, backgroundColor: c),
                            onTap: () async {
                              final lines = _viewerKey.currentState?.getSelectedTextLines();
                              if (lines != null && lines.isNotEmpty) {
                                final ann = HighlightAnnotation(textBoundsCollection: lines)
                                  ..color = c
                                  ..opacity = 0.35;
                                _controller.addAnnotation(ann);
                              }
                            },
                          ),

                        // Copy
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 18),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: d.selectedText ?? ''));
                          },
                        ),

                        // Close
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Close',
                          onPressed: () {
                            _controller.clearSelection();
                            _hidePopup();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Language dropdown + Translate button
                    Row(
                      children: [
                        DropdownMenu<String>(
                          initialSelection: _chosenLang,
                          onSelected: (value) {
                            if (value != null) {
                              setState(() => _chosenLang = value);
                            }
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'sv', label: 'Swedish'),
                            DropdownMenuEntry(value: 'en', label: 'English'),
                            DropdownMenuEntry(value: 'uk', label: 'Ukrainian'),
                          ],
                          label: const Text('Language'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: (_translating || (d.selectedText?.trim().isEmpty ?? true))
                              ? null
                              : () => _translateSelectedText(context, d),
                          child: _translating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Translate'),
                        ),
                      ],
                    ),

                    // Translation result area
                    if (_lastTranslation != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_lastTranslation!, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_popup!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF: Highlight + Instant Translate'),
        actions: [
          IconButton(icon: const Icon(Icons.folder_open), onPressed: _pickPdf),
        ],
      ),
      body: _bytes == null
          ? const Center(child: Text('Pick a PDF to start'))
          : SfPdfViewer.memory(
        _bytes!,
        key: _viewerKey,
        controller: _controller,
        canShowTextSelectionMenu: false, // we supply our own popup
        onTextSelectionChanged: (details) {
          if (details.selectedText == null || details.globalSelectedRegion == null) {
            _hidePopup();
          } else {
            _showPopup(context, details);
          }
        },
      ),
    );
  }
}
