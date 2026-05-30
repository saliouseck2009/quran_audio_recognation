import 'dart:math' as math;

import 'package:ayat_finder/core/constants/reciters.dart';
import 'package:ayat_finder/features/recognition/domain/entities/ayah_detection.dart';
import 'package:ayat_finder/features/recognition/domain/entities/history_entry.dart';
import 'package:ayat_finder/features/recognition/presentation/pages/mushaf_page.dart';
import 'package:ayat_finder/features/recognition/presentation/cubit/home_cubit.dart';
import 'package:ayat_finder/features/recognition/presentation/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_page_views.dart';
part '../widgets/home_page_cards.dart';
part '../widgets/home_page_components.dart';

class AyatHomePage extends StatefulWidget {
  const AyatHomePage({super.key, required this.controller});

  final HomeCubit controller;

  @override
  State<AyatHomePage> createState() => _AyatHomePageState();
}

class _AyatHomePageState extends State<AyatHomePage> {
  HomeCubit get controller => widget.controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openHistoryFromDrawer() {
    Navigator.of(context).pop();
    controller.openHistory();
  }

  void _openMushafFromDrawer() {
    Navigator.of(context).pop();
    final ayahs = controller.lastResult?.ayahs ?? <AyahDetection>[];
    final hasResult = ayahs.isNotEmpty;
    final surah = hasResult
        ? _surahName(
            controller.lastResult!.surahNumber ?? ayahs.first.surahNumber,
          )
        : 'Mushaf';
    final subtitle = hasResult
        ? (ayahs.length > 1
              ? 'versets ${ayahs.first.ayahNumber} → ${ayahs.last.ayahNumber}'
              : 'verset ${ayahs.first.ayahNumber}')
        : 'Lecture directe';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MushafPage(ayahs: ayahs, title: surah, subtitle: subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: controller,
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF08161B)),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Ayat Detector',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_rounded),
                    title: const Text('Ouvrir le Mushaf'),
                    onTap: _openMushafFromDrawer,
                  ),
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: const Text('Historique'),
                    onTap: _openHistoryFromDrawer,
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Paramètres'),
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.openSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: switch (state.phase) {
                AppPhase.onboarding => _OnboardingView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.idle => _IdleView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.recording => _RecordingView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.analyzing => _AnalyzingView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.result => _ResultView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.error => _ErrorView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.history => _HistoryView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
                AppPhase.settings => _SettingsView(
                  controller: controller,
                  onOpenDrawer: _openDrawer,
                ),
              },
            ),
          ),
        );
      },
    );
  }
}
