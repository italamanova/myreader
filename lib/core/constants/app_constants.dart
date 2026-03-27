/// Application-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Storage & File paths
  static const String booksFolder = 'MyBooks';
  static const String appDatabase = 'app_db';

  // Supported file extensions
  static const List<String> supportedFormats = ['pdf', 'epub'];

  // SharedPreferences keys
  static const String prefKeyTargetLang = 'targetLang';
  static const String prefKeyLastPagePrefix = 'lastPage_';

  // Default values
  static const String defaultTargetLanguage = 'uk';

  // Debounce durations
  static const Duration pageSaveDebounceDuration = Duration(milliseconds: 700);
  static const Duration pdfSaveDebounceDuration = Duration(seconds: 2);
  static const Duration translationDebounceDuration =
      Duration(milliseconds: 300);

  // Translation cache
  static const int translationCacheMaxSize = 100;

  // Supported languages for translation
  static const Map<String, String> supportedLanguages = {
    'sv': 'Swedish',
    'en': 'English',
    'uk': 'Ukrainian',
  };
}
