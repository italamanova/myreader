import 'package:flutter/material.dart';
import 'render_colored.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['DEEPL_API_KEY']!;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PdfReaderApp(apiKey: apiKey));
}

class PdfReaderApp extends StatelessWidget {
  final String apiKey;
  const PdfReaderApp({super.key, required this.apiKey});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: PdfTranslateAndHighlight(apiKey: apiKey),
      debugShowCheckedModeBanner: false,
    );
  }
}


