import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SelectAndColorPdf extends StatefulWidget {
  const SelectAndColorPdf({super.key});
  @override
  State<SelectAndColorPdf> createState() => _SelectAndColorPdfState();
}

class _SelectAndColorPdfState extends State<SelectAndColorPdf> {
  final _controller = PdfViewerController();
  final _viewerKey = GlobalKey<SfPdfViewerState>();
  Uint8List? _bytes;
  OverlayEntry? _menu;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (res != null) setState(() => _bytes = res.files.single.bytes);
  }

  void _showMenu(BuildContext context, PdfTextSelectionChangedDetails d) {
    // Position a tiny floating menu near the selected region
    final overlay = Overlay.of(context);
    final rect = d.globalSelectedRegion!;
    const menuWidth = 180.0, menuHeight = 56.0;

    _menu?.remove();
    _menu = OverlayEntry(
      builder: (_) => Positioned(
        left: (rect.left).clamp(8, MediaQuery.of(context).size.width - menuWidth - 8),
        top: (rect.top - menuHeight - 8).clamp(8, MediaQuery.of(context).size.height - menuHeight - 8),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: menuWidth,
            height: menuHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final color in [Colors.yellow, Colors.cyan, Colors.pinkAccent, Colors.lime])
                  InkWell(
                    onTap: () async {
                      final lines = _viewerKey.currentState?.getSelectedTextLines();
                      if (lines != null && lines.isNotEmpty) {
                        final ann = HighlightAnnotation(textBoundsCollection: lines);
                        ann.color = color;       // set highlight color
                        // ann.opacity = 0.7;      // optional: make it translucent
                        _controller.addAnnotation(ann);
                      }
                      _controller.clearSelection();
                      _menu?.remove(); _menu = null;
                    },
                    child: CircleAvatar(radius: 12, backgroundColor: color),
                  ),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 18),
                  tooltip: 'Copy',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: d.selectedText ?? ''));
                    _controller.clearSelection();
                    _menu?.remove(); _menu = null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(_menu!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select & Color PDF Text'),
        actions: [IconButton(icon: const Icon(Icons.folder_open), onPressed: _pick)],
      ),
      body: _bytes == null
          ? const Center(child: Text('Pick a PDF to start'))
          : SfPdfViewer.memory(
        _bytes!,
        key: _viewerKey,
        controller: _controller,
        canShowTextSelectionMenu: false, // we show our own menu
        onTextSelectionChanged: (details) {
          if (details.selectedText == null) {
            _menu?.remove(); _menu = null;
          } else {
            _showMenu(context, details);
          }
        },
      ),
    );
  }
}
