import 'package:flutter/material.dart';

class PdfSelectionPopup extends StatelessWidget {
  static const double width = 320;

  final Rect region;
  final String? selectedText;
  final String? translation;
  final bool translating;
  final String chosenLang;
  final ValueChanged<String>? onLangChanged;
  final VoidCallback? onTranslate;
  final VoidCallback? onClose;
  final VoidCallback? onCopy;
  final Function(Color)? onHighlight;

  const PdfSelectionPopup({
    super.key,
    required this.region,
    required this.selectedText,
    required this.translation,
    required this.translating,
    required this.chosenLang,
    this.onLangChanged,
    this.onTranslate,
    this.onClose,
    this.onCopy,
    this.onHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: (region.left).clamp(
        8,
        MediaQuery.of(context).size.width - width - 8,
      ),
      top: (region.top - 140).clamp(
        8,
        MediaQuery.of(context).size.height - 160,
      ),
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
                    for (final c in [
                      Colors.yellow,
                      Colors.cyan,
                      Colors.pinkAccent,
                      Colors.lime,
                    ])
                      InkWell(
                        child: CircleAvatar(radius: 12, backgroundColor: c),
                        onTap: () => onHighlight?.call(c),
                      ),

                    // Copy
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      tooltip: 'Copy',
                      onPressed: onCopy,
                    ),

                    // Close
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Close',
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Language dropdown + Translate button
                Row(
                  children: [
                    DropdownMenu<String>(
                      initialSelection: chosenLang,
                      onSelected: (value) {
                        if (value != null) {
                          onLangChanged?.call(value);
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
                      onPressed: (translating || (selectedText?.trim().isEmpty ?? true))
                          ? null
                          : onTranslate,
                      child: translating
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Translate'),
                    ),
                  ],
                ),

                // Translation result area
                if (translation != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      translation!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
