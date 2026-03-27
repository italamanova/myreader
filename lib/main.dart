import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/database/isar/isar_db.dart';
import 'features/library/presentation/pages/home_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await IsarDb.open();

  runApp(const MyReaderApp(home: HomePage()));
}
