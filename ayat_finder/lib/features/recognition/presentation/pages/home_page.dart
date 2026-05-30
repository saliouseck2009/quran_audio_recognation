import 'dart:math' as math;

import 'package:ayat_finder/features/recognition/domain/entities/ayah_detection.dart';
import 'package:ayat_finder/features/recognition/domain/entities/history_entry.dart';
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

  @override
  void initState() {
    super.initState();
    controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: controller,
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: switch (state.phase) {
                AppPhase.onboarding => _OnboardingView(controller: controller),
                AppPhase.idle => _IdleView(controller: controller),
                AppPhase.recording => _RecordingView(controller: controller),
                AppPhase.analyzing => _AnalyzingView(controller: controller),
                AppPhase.result => _ResultView(controller: controller),
                AppPhase.error => _ErrorView(controller: controller),
                AppPhase.history => _HistoryView(controller: controller),
              },
            ),
          ),
        );
      },
    );
  }
}
