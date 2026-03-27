import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Root application widget
class MyReaderApp extends StatelessWidget {
  const MyReaderApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Reader',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      scrollBehavior: MyScrollBehavior(),
      home: home,
    );
  }
}

/// Custom scroll behavior for desktop and mobile compatibility
class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}



