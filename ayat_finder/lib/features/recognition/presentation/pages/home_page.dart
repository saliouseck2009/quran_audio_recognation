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

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF04131A),
                    Color(0xFF0A252A),
                    Color(0xFF102F2A),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const _DrawerOrbMark(),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ayat detector',
                              style: TextStyle(
                                fontFamily: 'Times New Roman',
                                fontSize: 20,
                                color: Color(0xFFEDECE6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Identifie le verset récité',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFAAB6B3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFC9A85D),
                          Color(0xFF846A36),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NAVIGATION',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF748083),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DrawerNavItem(
                      icon: Icons.menu_book_outlined,
                      title: 'Ouvrir le Mushaf',
                      subtitle: 'Lecture page par page',
                      onTap: _openMushafFromDrawer,
                    ),
                    const SizedBox(height: 10),
                    _DrawerNavItem(
                      icon: Icons.history_rounded,
                      title: 'Historique',
                      subtitle: 'Tes versets identifiés',
                      onTap: _openHistoryFromDrawer,
                    ),
                    const SizedBox(height: 10),
                    _DrawerNavItem(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      subtitle: 'Récitateur · langue · thème',
                      onTap: () {
                        Navigator.of(context).pop();
                        controller.openSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(height: 1, color: Color(0xFFE0E4E5)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const Expanded(
                        child: Divider(height: 1, color: Color(0xFFE0E4E5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: TextStyle(
                      fontFamily: 'QuranHafs',
                      fontSize: 26,
                      color: Color(0xFF8D6E38),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ayat detector · v1.0',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 13,
                      color: Color(0xFF8D979A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          drawer: _buildDrawer(),
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

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECE0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2D7C1)),
                ),
                child: Icon(icon, color: const Color(0xFF243136), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18242A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6C777B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB3BCBF),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerOrbMark extends StatelessWidget {
  const _DrawerOrbMark();

  @override
  Widget build(BuildContext context) {
    const points = <Offset>[
      Offset(-26, -20),
      Offset(22, -20),
      Offset(-22, 22),
      Offset(24, 18),
      Offset(-30, 4),
      Offset(0, -30),
      Offset(30, 0),
      Offset(-2, 30),
    ];

    return Stack(
      alignment: Alignment.center,
      children: [
        for (var index = 0; index < points.length; index++)
          Transform.translate(
            offset: points[index],
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index.isEven
                    ? const Color(0xFFC9A85D)
                    : const Color(0xFF2E5A50),
              ),
            ),
          ),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFF7EFCF), Color(0xFFC9A85D)],
            ),
          ),
        ),
      ],
    );
  }
}
