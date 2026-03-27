import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';

/// Wrapper for app-wide shared preferences
class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  /// Get the current target translation language
  String get targetLanguage {
    return _prefs.getString(AppConstants.prefKeyTargetLang) ??
        AppConstants.defaultTargetLanguage;
  }

  /// Set the target translation language
  Future<void> setTargetLanguage(String lang) async {
    await _prefs.setString(AppConstants.prefKeyTargetLang, lang);
  }

  /// Get the last viewed page for a specific book
  int? getLastPage(String bookPath) {
    return _prefs.getInt('${AppConstants.prefKeyLastPagePrefix}$bookPath');
  }

  /// Set the last viewed page for a specific book
  Future<void> setLastPage(String bookPath, int pageNumber) async {
    await _prefs.setInt(
        '${AppConstants.prefKeyLastPagePrefix}$bookPath', pageNumber);
  }

  /// Get all preference keys (useful for clearing)
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Clear all preferences
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// Initialize and get AppPreferences singleton
Future<AppPreferences> initAppPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return AppPreferences(prefs);
}
