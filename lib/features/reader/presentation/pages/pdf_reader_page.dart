import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/preferences/app_preferences.dart';
import '../../../../core/services/translation/translation_service.dart';
import '../../../words/data/repositories/words_repository.dart';
import '../../../words/presentation/widgets/saved_words_panel.dart';
import '../widgets/text_selection_popup.dart';

/// PDF reader page with translation and annotation support
class PdfReaderPage extends StatefulWidget{
  const PdfReaderPage({
    super.key,
    this.apiKey,
    required this.filePath,
    this.appPreferences,
  });

  final String? apiKey;
  final File filePath;
  final AppPreferences? appPreferences;

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> with WidgetsBindingObserver{
  final _viewerKey = GlobalKey<SfPdfViewerState>();
  late final PdfViewerController _controller;
  late final TranslationService _translator;
  late final WordsRepository _wordsRepository;
  late AppPreferences _appPreferences;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);

  OverlayEntry? _popup;
  String _targetLang = AppConstants.defaultTargetLanguage;
  int _currentPage = 1;
  int _totalPages = 0;

  Timer? _pageSaveDebounce;
  Timer? _pdfSaveDebounce;
  int? _lastSavedPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = PdfViewerController();
    final apiKey = widget.apiKey ?? dotenv.env['DEEPL_API_KEY']!;
    _translator = DeepLTranslationService(apiKey);
    _wordsRepository = WordsRepository();

    _initializePreferences();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lastPage = await _loadLastPage();
      if (lastPage != null) {
        _currentPage = lastPage;
        _currentPageNotifier.value = lastPage;
        _lastSavedPage = lastPage;
        _controller.jumpToPage(lastPage);
      }
    });
  }

  Future<void> _initializePreferences() async {
    if (widget.appPreferences != null) {
      _appPreferences = widget.appPreferences!;
    } else {
      _appPreferences = await initAppPreferences();
    }
    _loadTargetLanguage();
  }

  void _scheduleAutoSave() {
    _pdfSaveDebounce?.cancel();
    _pdfSaveDebounce = Timer(AppConstants.pdfSaveDebounceDuration, () async {
      await _autoSave();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushLastPageSave();
    _pageSaveDebounce?.cancel();
    _pdfSaveDebounce?.cancel();
    _popup?.remove();
    _currentPageNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _flushLastPageSave();
    }
  }

  void _onPdfPageChanged(PdfPageChangedDetails details) {
    final newPage = details.newPageNumber;

    if (newPage == _currentPage) return;

    _currentPage = newPage;

    if (_currentPageNotifier.value != newPage) {
      _currentPageNotifier.value = newPage;
    }

    if (_lastSavedPage == newPage) return; // CHANGED: do not schedule a save for a page already persisted

    _pageSaveDebounce?.cancel();
    _pageSaveDebounce = Timer(
      const Duration(seconds: 2),
          () async {
        if (_lastSavedPage == _currentPage) return; // CHANGED
        await _saveLastPage(_currentPage);
        _lastSavedPage = _currentPage;
      },
    );
  }


  Future<void> _flushLastPageSave() async {
    _pageSaveDebounce?.cancel();

    if (_lastSavedPage == _currentPage) return;

    await _saveLastPage(_currentPage);
    _lastSavedPage = _currentPage;
  }

  Future<void> _saveLastPage(int page) async {
    await _appPreferences.setLastPage(widget.filePath.path, page);
  }

  Future<int?> _loadLastPage() async {
    return _appPreferences.getLastPage(widget.filePath.path);
  }

  Future<void> _autoSave() async {
    try {
      final bytes = await _controller.saveDocument(
        flattenOption: PdfFlattenOption.none,
      );
      final tempPath = '${widget.filePath.path}.tmp';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes, flush: true);
      await tempFile.rename(widget.filePath.path);
    } catch (e) {
      debugPrint('Auto-save failed: $e');
      try {
        await File('${widget.filePath.path}.tmp').delete();
      } catch (_) {}
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
    final saved = _appPreferences.targetLanguage;
    setState(() => _targetLang = saved);
  }

  Future<void> _saveTargetLanguage(String lang) async {
    await _appPreferences.setTargetLanguage(lang);
  }

  String _langLabel(String code) {
    return AppConstants.supportedLanguages[code] ?? code.toUpperCase();
  }

  String _langShortLabel(String code) {
    final label = _langLabel(code);
    return label.substring(0, 2).toUpperCase();
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
            final isSmallScreen = MediaQuery.sizeOf(context).width < 600;

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
                  itemBuilder: (context) => AppConstants.supportedLanguages.entries
                      .map((entry) => PopupMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                if (_targetLang == entry.key)
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                if (_targetLang == entry.key) const SizedBox(width: 8),
                                Text(entry.value),
                              ],
                            ),
                          ))
                      .toList(),
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
            onPageChanged: _onPdfPageChanged,
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
                    _controller.jumpToPage(pageNumber);
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

