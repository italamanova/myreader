import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../translation_service.dart';
import '../words/saved_words_panel.dart';
import '../words/word_repository.dart';
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
  late final WordsRepository _wordsRepository;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);

  OverlayEntry? _popup;
  String _targetLang = 'uk';
  int _currentPage = 1;
  int _totalPages = 0;

  Timer? _pageSaveDebounce;
  Timer? _pdfSaveDebounce;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    final apiKey = widget.apiKey ?? dotenv.env['DEEPL_API_KEY']!;
    _translator = DeepLTranslationService(apiKey);
    _wordsRepository = WordsRepository();

    _loadTargetLanguage();

    // Restore last page
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lastPage = await _loadLastPage();
      if (lastPage != null) {
        _controller.jumpToPage(lastPage);
      }
    });
  }

  void _debouncedSaveLastPage(int page) {
    _pageSaveDebounce?.cancel();
    _pageSaveDebounce = Timer(const Duration(milliseconds: 700), () {
      _saveLastPage(page);
    });
  }

  void _scheduleAutoSave() {
    // CHANGED: debounce full PDF writes because saveDocument() is expensive
    _pdfSaveDebounce?.cancel();
    _pdfSaveDebounce = Timer(const Duration(seconds: 2), () async {
      await _autoSave();
    });
  }

  @override
  void dispose() {
    _pageSaveDebounce?.cancel();
    _pdfSaveDebounce?.cancel();
    _popup?.remove();
    _currentPageNotifier.dispose();
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

        onSaveWord: (word, translation) async {
          await _wordsRepository.addWord(
            word: word,
            translation: translation,
            bookPath: widget.filePath.path,
            pageNumber: _currentPage,
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved: "$word"'),
              duration: const Duration(seconds: 2),
            ),
          );
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

  String _langShortLabel(String code) {
    switch (code) {
      case 'sv':
        return 'SV';
      case 'en':
        return 'EN';
      case 'uk':
        return 'UK';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Builder(
          builder: (context) {
            final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

            if (isSmallScreen) {
              return ValueListenableBuilder<int>(
                valueListenable: _currentPageNotifier,
                builder: (context, page, _) {
                  return Text(
                    '$page / $_totalPages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              );
            }

            return Text(
              widget.filePath.path.split('/').last.replaceAll('.pdf', ''),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            );
          },
        ),
        flexibleSpace: Builder(
          builder: (context) {
            final isSmallScreen = MediaQuery.sizeOf(context).width < 600; // CHANGED: hide centered page counter on small screens

            if (isSmallScreen) {
              return const SizedBox.shrink();
            }

            return SafeArea(
              child: Center(
                child: IgnorePointer(
                  ignoring: true,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPageNotifier,
                    builder: (context, page, _) {
                      return Text(
                        '$page / $_totalPages',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Builder(
              builder: (context) {
                final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

                return PopupMenuButton<String>(
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
                      child: Row(
                        children: [
                          if (_targetLang == 'sv')
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          if (_targetLang == 'sv') const SizedBox(width: 8),
                          const Text('Swedish'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'en',
                      child: Row(
                        children: [
                          if (_targetLang == 'en')
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          if (_targetLang == 'en') const SizedBox(width: 8),
                          const Text('English'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'uk',
                      child: Row(
                        children: [
                          if (_targetLang == 'uk')
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          if (_targetLang == 'uk') const SizedBox(width: 8),
                          const Text('Ukrainian'),
                        ],
                      ),
                    ),
                  ],
                  child: Material(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 10 : 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.translate_rounded,
                            size: isSmallScreen ? 16 : 18,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSmallScreen
                                ? _langShortLabel(_targetLang)
                                : _langLabel(_targetLang),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            size: isSmallScreen ? 18 : 22,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final pdfViewer = SfPdfViewer.file(
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
              _currentPage = d.newPageNumber;
              _currentPageNotifier.value = d.newPageNumber;
              _debouncedSaveLastPage(d.newPageNumber);
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
            onAnnotationAdded: (_) => _scheduleAutoSave(),
            onAnnotationRemoved: (_) => _scheduleAutoSave(),
            onAnnotationEdited: (_) => _scheduleAutoSave(),
          );
          if (!isWide) {
            return pdfViewer;
          }
          return Row(
            children: [
              Expanded(child: pdfViewer),
              const VerticalDivider(width: 1),

              SizedBox(
                width: 360,
                child: SavedWordsPanel(
                  repository: _wordsRepository,
                  bookPath: widget.filePath.path,
                  onJumpToPage: (pageNumber) {
                    _controller.jumpToPage(pageNumber); // CHANGED
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
