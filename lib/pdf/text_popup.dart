import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../translation_service.dart';

class TextSelectionPopup extends StatefulWidget {
  const TextSelectionPopup({
    super.key,
    required this.region,
    required this.selectedText,
    required this.targetLang,
    required this.translator,
    required this.controller,
    required this.getSelectedTextLines,
    required this.onClose,
  });

  final Rect region;
  final String selectedText;
  final String targetLang;
  final TranslationService translator;
  final PdfViewerController controller;
  final List<PdfTextLine> Function() getSelectedTextLines;
  final VoidCallback onClose;

  @override
  State<TextSelectionPopup> createState() => _TextSelectionPopupState();
}

class _TextSelectionPopupState extends State<TextSelectionPopup> {
  bool _translating = false;
  String? _translation;
  String? _lastKey; // prevents re-calling API for same text/lang

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _translateIfNeeded());
  }

  @override
  void didUpdateWidget(covariant TextSelectionPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedText != widget.selectedText ||
        oldWidget.targetLang != widget.targetLang) {
      _translateIfNeeded();
    }
  }

  Future<void> _translateIfNeeded() async {
    final text = widget.selectedText.trim();
    if (text.isEmpty) return;

    final key = '${widget.targetLang}::$text';
    if (key == _lastKey) return;
    _lastKey = key;

    if (!mounted) return;
    setState(() {
      _translating = true;
      _translation = null;
    });

    try {
      final result = await widget.translator.translate(
        text: text,
        targetLang: widget.targetLang,
      );
      if (!mounted) return;
      setState(() => _translation = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _translation = 'Something went wrong');
    } finally {
      if (!mounted) return;
      setState(() => _translating = false);
    }
  }

  void _highlight(Color color) {
    final lines = widget.getSelectedTextLines();
    if (lines.isEmpty) return;

    final ann = HighlightAnnotation(textBoundsCollection: lines)
      ..color = color
      ..opacity = 1.0;

    widget.controller.addAnnotation(ann);
  }

  @override
  Widget build(BuildContext context) {
    const double popupWidth = 320;
    const double margin = 12;

    final r = widget.region;
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;

    double left = r.center.dx - popupWidth / 2;
    left = left.clamp(margin, screenWidth - popupWidth - margin);

    // Place above if possible, otherwise below
    final double preferredTop = r.top - 180;
    final double top = preferredTop < media.padding.top + margin
        ? r.bottom + 14
        : preferredTop;

    final cs = Theme.of(context).colorScheme;

    Widget iconChip({
      required IconData icon,
      required Color iconColor,
      required VoidCallback onTap,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: popupWidth),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  color: Colors.black26,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row of minimal buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                    Row(
                      children: [
                        iconChip(
                          icon: Icons.copy,
                          iconColor: cs.onSurfaceVariant,
                          onTap: () => Clipboard.setData(
                            ClipboardData(text: widget.selectedText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        iconChip(
                          icon: Icons.close,
                          iconColor: cs.onSurfaceVariant,
                          onTap: widget.onClose,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Translation area only
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: _translating
                      ? const SizedBox(
                    height: 18,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                      : Text(
                    (_translation ?? '').trim(),
                    style: Theme.of(context).textTheme.bodyMedium,
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