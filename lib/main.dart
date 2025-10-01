import 'package:flutter/material.dart';
import 'pdf_translate_and_highlight.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_page.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'My Reader',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}


