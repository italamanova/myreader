import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../translation_service.dart';

class TextSelectionPopup extends StatefulWidget {
  const TextSelectionPopup({
    super.key,
    required this.region,
    required this.selectedText,
    required this.translator,
    required this.controller,
    required this.getSelectedTextLines,
    required this.onClose,
  });

  final Rect region;
  final String selectedText;
  final TranslationService translator;
  final PdfViewerController controller;
  final List<PdfTextLine> Function() getSelectedTextLines;
  final VoidCallback onClose;

  @override
  State<TextSelectionPopup> createState() => _TextSelectionPopupState();
}

class _TextSelectionPopupState extends State<TextSelectionPopup> {
  String _chosenLang = 'uk'; // default language
  bool _translating = false;
  String? _translation;

  // Translation
  Future<void> _translate() async {
    if (widget.selectedText.trim().isEmpty) return;
    setState(() => _translating = true);
    try {
      final result = await widget.translator.translate(
        text: widget.selectedText.trim(),
        targetLang: _chosenLang,
      );
      setState(() => _translation = result);
    } catch (e) {
      setState(() => _translation = 'Translation failed: $e');
    } finally {
      setState(() => _translating = false);
    }
  }

  // Highlighting
  void _highlight(Color color) {
    final lines = widget.getSelectedTextLines();
    if (lines.isNotEmpty) {
      final ann = HighlightAnnotation(textBoundsCollection: lines)
        ..color = color
        ..opacity = 1.0;
      widget.controller.addAnnotation(ann);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = widget.region.top - 200;

    const double popupWidth = 320;
    const double margin = 12;

    final r = widget.region;
    final screenWidth = MediaQuery.of(context).size.width;

    // **ADJUSTED**: anchor horizontally to selection center
    double left = r.center.dx - popupWidth / 2;

    // **ADJUSTED**: clamp popup inside screen
    left = left.clamp(margin, screenWidth - popupWidth - margin);

    final double topCandidate = r.top - 200;

    return Positioned(
      left: left,
      top: topCandidate < 0 ? r.bottom + 20 : topCandidate,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: popupWidth,
          child: Container(
            width: popupWidth,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header bar ---
                Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.circle,
                                color: Colors.yellowAccent,
                              ),
                              tooltip: 'Highlight yellow',
                              onPressed: () => _highlight(Colors.yellowAccent),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.circle,
                                color: Colors.lightGreenAccent,
                              ),
                              tooltip: 'Highlight green',
                              onPressed: () =>
                                  _highlight(Colors.lightGreenAccent),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.circle,
                                color: Colors.pinkAccent,
                              ),
                              tooltip: 'Highlight pink',
                              onPressed: () => _highlight(Colors.pinkAccent),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy text',
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: widget.selectedText),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      DropdownMenu<String>(
                        initialSelection: _chosenLang,
                        onSelected: (v) => setState(() => _chosenLang = v!),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 'sv', label: 'Swedish'),
                          DropdownMenuEntry(value: 'en', label: 'English'),
                          DropdownMenuEntry(value: 'uk', label: 'Ukrainian'),
                        ],
                        label: const Text('Language'),
                      ),

                      const Spacer(),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.translate),
                        label: const Text('Translate'),
                        onPressed: _translate,
                      ),
                    ],
                  ),
                ),

                // --- Translation output or progress ---
                if (_translating)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_translation != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: popupWidth - 24,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            _translation!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
