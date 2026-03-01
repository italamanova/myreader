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
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  final _viewerKey = GlobalKey<SfPdfViewerState>();
  late final PdfViewerController _controller;
  late final TranslationService _translator;
  OverlayEntry? _popup;
  String _targetLang = 'uk';
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    final apiKey = widget.apiKey ?? dotenv.env['DEEPL_API_KEY']!;
    _translator = DeepLTranslationService(apiKey);

    _loadTargetLanguage();

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
      final bytes = await _controller.saveDocument(
        flattenOption: PdfFlattenOption.none,
      );
      await widget.filePath.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('Auto-save failed: $e');
    }
  }

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
        targetLang: _targetLang,
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

  Future<void> _loadTargetLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('targetLang');
    if (saved != null && saved.isNotEmpty) {
      setState(() => _targetLang = saved);
    }
  }

  Future<void> _saveTargetLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetLang', lang);
  }

  String _langLabel(String code) {
    switch (code) {
      case 'sv':
        return 'Swedish';
      case 'en':
        return 'English';
      case 'uk':
        return 'Ukrainian';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.filePath.path
              .split('/')
              .last
              .replaceAll('.pdf', ''),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),

        // 📄 Page count centered
        flexibleSpace: SafeArea(
          child: Center(
            child: IgnorePointer(
              ignoring: true, // prevents blocking buttons
              child: Text(
                '$_currentPage / $_totalPages',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Translate to',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Translation language',
                  initialValue: _targetLang,
                  position: PopupMenuPosition.under,
                  onSelected: (lang) {
                    setState(() => _targetLang = lang);
                    _saveTargetLanguage(lang);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'sv',
                      child: Text(
                        'Swedish',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'en',
                      child: Text(
                        'English',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'uk',
                      child: Text(
                        'Ukrainian',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE0B2),
                      foregroundColor: const Color(0xFFE65100),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _langLabel(_targetLang),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SfPdfViewer.file(
        widget.filePath,
        key: _viewerKey,
        controller: _controller,
        canShowTextSelectionMenu: false,
        onDocumentLoaded: (d) {
          setState(() {
            _totalPages = d.document.pages.count;
          });
        },

        onPageChanged: (d) {
          setState(() {
            _currentPage = d.newPageNumber;
          });
          _saveLastPage(d.newPageNumber);
        },

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
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
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
