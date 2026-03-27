import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

import '../../data/models/word_entry.dart';
import '../../data/repositories/words_repository.dart';

/// Panel widget displaying saved words grouped by page
class SavedWordsPanel extends StatelessWidget {
  const SavedWordsPanel({
    super.key,
    required this.repository,
    required this.bookPath,
    required this.onJumpToPage,
  });

  final WordsRepository repository;
  final String bookPath;
  final void Function(int pageNumber) onJumpToPage;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Saved words',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<WordEntry>>(
                stream: repository.watchWordsForBook(bookPath),
                builder: (context, snapshot) {
                  final words = snapshot.data ?? const <WordEntry>[];

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      words.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (words.isEmpty) {
                    return const Center(
                      child: Text('No saved words yet.'),
                    );
                  }

                  // Group by page
                  final Map<int, List<WordEntry>> byPage = {};
                  for (final w in words) {
                    byPage.putIfAbsent(w.pageNumber, () => []).add(w);
                  }
                  final pages = byPage.keys.toList()..sort();

                  return ListView.builder(
                    key: ValueKey('words_$bookPath'),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      final pageWords = byPage[page]!
                        ..sort((a, b) => a.wordOriginal.compareTo(b.wordOriginal));

                      return _PageExpansionTile(
                        key: ValueKey('page_$page'),
                        pageNumber: page,
                        entries: pageWords,
                        onJumpToPage: onJumpToPage,
                        onDelete: (Id id) => repository.deleteWord(id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Expansion tile for a single page of words
class _PageExpansionTile extends StatefulWidget {
  const _PageExpansionTile({
    Key? key,
    required this.pageNumber,
    required this.entries,
    required this.onJumpToPage,
    required this.onDelete,
  }) : super(key: key);

  final int pageNumber;
  final List<WordEntry> entries;
  final void Function(int pageNumber) onJumpToPage;
  final Future<void> Function(Id id) onDelete;

  @override
  State<_PageExpansionTile> createState() => _PageExpansionTileState();
}

class _PageExpansionTileState extends State<_PageExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        title: Text('Page ${widget.pageNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Go to page',
              onPressed: () => widget.onJumpToPage(widget.pageNumber),
              icon: const Icon(Icons.open_in_new),
            ),
            Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          ],
        ),
        children: [
          for (final e in widget.entries)
            ListTile(
              dense: true,
              title: Text(e.wordOriginal),
              subtitle: (e.translation != null && e.translation!.trim().isNotEmpty)
                  ? Text(e.translation!)
                  : null,
              trailing: IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => widget.onDelete(e.id),
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}


