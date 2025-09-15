import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class TranslationService {
  Future<String> translate({
    required String text,
    required String targetLang,
    String sourceLang = '',
  });
}

class DeepLTranslationService implements TranslationService {
  final String apiKey; // keep secret!
  DeepLTranslationService(this.apiKey);

  @override
  Future<String> translate({
    required String text,
    required String targetLang,
    String sourceLang = '',
  }) async {
    final resp = await http.post(
      Uri.parse('https://api-free.deepl.com/v2/translate'),
      headers: {'Authorization': 'DeepL-Auth-Key $apiKey'},
      body: {
        'text': text,
        'target_lang': targetLang.toUpperCase(), // e.g. SV, EN, ES
        if (sourceLang.isNotEmpty) 'source_lang': sourceLang.toUpperCase(),
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('Translate failed: ${resp.statusCode} ${resp.body}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return (json['translations'] as List).first['text'] as String;
  }
}
