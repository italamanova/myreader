import 'package:flutter/material.dart';

/// Application routes
class Routes {
  Routes._();

  // Home and navigation
  static const String home = '/';

  // Readers
  static const String pdfReader = '/pdf-reader';
  static const String epubReader = '/epub-reader';

  // Words
  static const String wordCards = '/word-cards';

  /// Route definitions (future expansion for named routes)
  static Map<String, WidgetBuilder> getRoutes() {
    return {};
  }
}

