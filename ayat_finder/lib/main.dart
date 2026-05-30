import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

import 'core/di/service_locator.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const AyatFinderApp());
  _preloadMushafFontsInBackground();
}

void _preloadMushafFontsInBackground() {
  Future<void>(() async {
    try {
      await QcfFontLoader.setupFontsAtStartup(onProgress: (progress) => null);
    } catch (_) {
      // Optional preload only; ignore failures to avoid affecting app startup.
    }
  });
}
