import 'package:flutter/material.dart';
import 'render_colored.dart';
import 'render_as_jpeg.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PdfReaderApp());
}

class PdfReaderApp extends StatelessWidget {
  const PdfReaderApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SelectAndColorPdf(),
      // home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


