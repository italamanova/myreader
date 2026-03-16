import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'entries/word_entry.dart';
import 'word_repository.dart';

class WordCardsPage extends StatelessWidget {
  const WordCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = WordsRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Word cards')),
      body: StreamBuilder<List<WordEntry>>(
        stream: repository.watchAllWords(),
        builder: (context, snapshot) {
          final words = snapshot.data ?? const <WordEntry>[];

          if (snapshot.connectionState == ConnectionState.waiting &&
              words.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (words.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No saved words yet.', textAlign: TextAlign.center),
              ),
            );
          }

          return _WordCardsPager(words: words, repository: repository);
        },
      ),
    );
  }
}

class _WordCardsPager extends StatefulWidget {
  const _WordCardsPager({
    required this.words,
    required this.repository,
  });

  final List<WordEntry> words;
  final WordsRepository repository;

  @override
  State<_WordCardsPager> createState() => _WordCardsPagerState();
}

class _WordCardsPagerState extends State<_WordCardsPager> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteCurrentCard() async {
    if (widget.words.isEmpty) return;

    final current = widget.words[_currentIndex];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete word?'),
        content: Text(
          'Delete "${current.wordOriginal}" from saved words?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await widget.repository.deleteWord(current.id); // CHANGED: delete the current card using existing repository method

    if (!mounted) return;

    final nextIndex = _currentIndex >= widget.words.length - 1
        ? (_currentIndex > 0 ? _currentIndex - 1 : 0)
        : _currentIndex;

    setState(() {
      _currentIndex = nextIndex; // CHANGED: keep index valid after deleting the current card
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${current.wordOriginal}"'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.words[_currentIndex];

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Tap the card to flip it',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentIndex + 1} / ${widget.words.length}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        IconButton.filledTonal(
          onPressed: _deleteCurrentCard, // CHANGED: delete the currently visible word card
          tooltip: 'Delete word',
          icon: const Icon(Icons.delete_outline),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.words.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final entry = widget.words[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: _FlipWordCard(entry: entry),
              );
            },
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 20)),
      ],
    );
  }
}

class _FlipWordCard extends StatefulWidget {
  const _FlipWordCard({required this.entry});

  final WordEntry entry;

  @override
  State<_FlipWordCard> createState() => _FlipWordCardState();
}

class _FlipWordCardState extends State<_FlipWordCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
  }

  @override
  void didUpdateWidget(covariant _FlipWordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _controller.value = 0;
      _showFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translation = widget.entry.translation?.trim();
    final hasTranslation = translation != null && translation.isNotEmpty;

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final isFrontVisible = angle <= math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: isFrontVisible
                ? _CardFace(
                    title: 'Word',
                    text: widget.entry.wordOriginal,
                    hint: 'Tap to see translation',
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      title: 'Translation',
                      text: hasTranslation
                          ? translation
                          : 'No translation saved',
                      hint: 'Tap to go back',
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.title,
    required this.text,
    required this.hint,
  });

  final String title;
  final String text;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 8),
            color: Colors.black12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
