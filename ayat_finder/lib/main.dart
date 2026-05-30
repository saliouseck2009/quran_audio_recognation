import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const AyatFinderApp());
}
