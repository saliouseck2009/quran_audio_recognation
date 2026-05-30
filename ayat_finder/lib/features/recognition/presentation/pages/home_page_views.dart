part of 'home_page.dart';

class _AppHeader extends StatelessWidget {
  const _AppHeader({this.actionIcon, this.onAction});

  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Ayat Detector',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 42,
            color: Color(0xFF162126),
          ),
        ),
        const Spacer(),
        if (actionIcon != null)
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onAction,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF0EE),
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, color: const Color(0xFF39484D)),
            ),
          ),
      ],
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        const _AppHeader(),
        const SizedBox(height: 26),
        const _OrbWidget(size: 150),
        const SizedBox(height: 46),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Times New Roman',
              fontSize: 24,
              height: 1.08,
              color: Color(0xFF172126),
            ),
            children: [
              TextSpan(text: 'Reconnais\n'),
              TextSpan(
                text: 'n’importe quel verset\n',
                style: TextStyle(
                  color: Color(0xFFA7884B),
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(text: 'en quelques secondes.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enregistre une récitation, et retrouve\nla sourate, le verset, et son texte arabe.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, height: 1.5, color: Color(0xFF6E787C)),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: controller.requestMicrophonePermission,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF08161B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            icon: const Icon(Icons.mic_none_rounded),
            label: const Text(
              'Autoriser le microphone',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'L’audio n’est jamais conservé sur nos serveurs.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF7D8588)),
        ),
      ],
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _AppHeader(
          actionIcon: Icons.settings_outlined,
          onAction: controller.openSettings,
        ),
        const SizedBox(height: 40),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'PRÊT À ÉCOUTER',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C868A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Récite, ou capte une\nrécitation autour\nde toi.',
            style: TextStyle(
              fontFamily: 'Times New Roman',
              fontSize: 24,
              height: 1.05,
              color: Color(0xFF172126),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Réciteur audio: ${_reciterLabelById(controller.selectedReciterId)}',
          style: const TextStyle(fontSize: 14, color: Color(0xFF7B8588)),
        ),
        const SizedBox(height: 22),
        const _OrbWidget(size: 150),
        const SizedBox(height: 48),
        InkWell(
          onTap: controller.startRecording,
          borderRadius: BorderRadius.circular(58),
          child: Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              color: const Color(0xFF08161B),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDCA9D), width: 3),
            ),
            child: const Icon(
              Icons.mic_none_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Maintiens pour parler · Tape pour enregistrer',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF7D8588)),
        ),
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: controller.openHistory,
          icon: const Icon(Icons.history_rounded),
          label: const Text('Voir l’historique'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _RecordingView extends StatelessWidget {
  const _RecordingView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _AppHeader(
          actionIcon: Icons.settings_outlined,
          onAction: controller.openSettings,
        ),
        const SizedBox(height: 26),
        const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFF1E9D5),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '● REC',
              style: TextStyle(
                color: Color(0xFF9C7E46),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'ÉCOUTE EN COURS',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 3,
            color: Color(0xFF94763E),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          controller.formatDuration(controller.recordingDuration),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 92,
            fontFamily: 'Times New Roman',
            color: Color(0xFF172126),
          ),
        ),
        const SizedBox(height: 16),
        const _OrbWidget(size: 150),
        const SizedBox(height: 20),
        const _WaveBars(),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CircleIconButton(
              icon: controller.isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              onTap: controller.pauseOrResumeRecording,
            ),
            _CircleIconButton(
              icon: Icons.stop_rounded,
              dark: true,
              size: 128,
              iconSize: 56,
              onTap: controller.stopAndAnalyze,
            ),
            _CircleIconButton(
              icon: Icons.close_rounded,
              onTap: controller.cancelRecording,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _AppHeader(
          actionIcon: Icons.settings_outlined,
          onAction: controller.openSettings,
        ),
        const SizedBox(height: 24),
        const _OrbWidget(size: 150),
        const SizedBox(height: 22),
        const Text(
          'ANALYSE',
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 3,
            color: Color(0xFF94763E),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Identification du verset...',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 24,
            height: 1.1,
            color: Color(0xFF172126),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Comparaison avec les 6 236 versets du Coran.',
          style: TextStyle(fontSize: 18, color: Color(0xFF6E787C)),
        ),
        const SizedBox(height: 24),
        _StepCard(label: 'Audio reçu', done: controller.audioReceived),
        const SizedBox(height: 10),
        _StepCard(label: 'Transcription', done: controller.transcriptionDone),
        const SizedBox(height: 10),
        _StepCard(label: 'Correspondance', done: controller.matchingDone),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.lastResult!;
    final ayahs = result.ayahs;
    final surah = _surahName(result.surahNumber ?? ayahs.first.surahNumber);
    final isSequence = ayahs.length > 1;
    final subtitle = isSequence
        ? 'versets ${ayahs.first.ayahNumber} → ${ayahs.last.ayahNumber}'
        : 'verset ${ayahs.first.ayahNumber}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppHeader(
          actionIcon: Icons.settings_outlined,
          onAction: controller.openSettings,
        ),
        const SizedBox(height: 26),
        Text(
          isSequence
              ? '${ayahs.length} versets reconnus'
              : '1 verset identifié',
          style: const TextStyle(
            fontSize: 17,
            letterSpacing: 3,
            color: Color(0xFF768286),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Times New Roman',
              fontSize: 24,
              color: Color(0xFF172126),
            ),
            children: [
              TextSpan(text: 'Sourate $surah\n'),
              TextSpan(
                text: subtitle,
                style: const TextStyle(
                  color: Color(0xFFA7884B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Réciteur: ${_reciterLabelById(controller.selectedReciterId)}',
          style: const TextStyle(fontSize: 14, color: Color(0xFF7B8588)),
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFBE9F63), thickness: 4),
        const SizedBox(height: 12),
        if (!isSequence)
          _SingleAyahCard(
            ayah: ayahs.first,
            transcription: result.transcription,
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: ayahs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _SequenceAyahCard(ayah: ayahs[index]),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.toggleResultAudioPlayback,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: controller.isAudioLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        controller.isResultAudioPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                      ),
                label: Text(
                  controller.isResultAudioPlaying ? 'Stop' : 'Écouter',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: controller.openHistory,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Historique', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
        if (controller.errorMessage != null) ...[
          const SizedBox(height: 6),
          Text(
            controller.errorMessage!,
            style: const TextStyle(fontSize: 14, color: Color(0xFFB95038)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: controller.backToIdle,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF08161B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.mic_none_rounded),
            label: const Text('Nouveau', style: TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        _AppHeader(
          actionIcon: Icons.settings_outlined,
          onAction: controller.openSettings,
        ),
        const SizedBox(height: 26),
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEDEAE0), width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFC25D3F),
              size: 68,
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'Aucun verset reconnu.',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 24,
            height: 1.1,
            color: Color(0xFF172126),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Text(
          controller.errorMessage ??
              'La récitation était peut-être trop courte ou trop bruitée.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            height: 1.4,
            color: Color(0xFF6D777B),
          ),
        ),
        const SizedBox(height: 22),
        const _HintPill('Récite au moins 3 à 4 secondes'),
        const SizedBox(height: 10),
        const _HintPill('Éloigne-toi des sources de bruit'),
        const SizedBox(height: 10),
        const _HintPill('Articule clairement les voyelles longues'),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.backToIdle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text('Annuler', style: TextStyle(fontSize: 21)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: controller.retry,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF08161B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                icon: const Icon(Icons.mic_none_rounded),
                label: const Text('Réessayer', style: TextStyle(fontSize: 21)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppHeader(
          actionIcon: Icons.settings_outlined,
          onAction: controller.openSettings,
        ),
        const SizedBox(height: 24),
        const Text(
          'Historique',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 24,
            color: Color(0xFF172126),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${controller.history.length} reconnaissances',
          style: const TextStyle(fontSize: 19, color: Color(0xFF7B8588)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: controller.history.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune reconnaissance pour le moment.',
                    style: TextStyle(fontSize: 20, color: Color(0xFF6B7478)),
                  ),
                )
              : ListView.separated(
                  itemCount: controller.history.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = controller.history[index];
                    return _HistoryCard(item: item);
                  },
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: controller.backToIdle,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF08161B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Fermer', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({required this.controller});

  final HomeCubit controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AppHeader(
          actionIcon: Icons.close_rounded,
          onAction: controller.backToIdle,
        ),
        const SizedBox(height: 24),
        const Text(
          'Paramètres',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 26,
            color: Color(0xFF172126),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choisis le réciteur utilisé pendant la lecture audio.',
          style: TextStyle(fontSize: 16, color: Color(0xFF6C777B)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: kReciterOptions.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final reciter = kReciterOptions[index];
              final isSelected = reciter.id == controller.selectedReciterId;
              return InkWell(
                onTap: () => controller.setSelectedReciter(reciter.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFB89A5C)
                          : const Color(0xFFE4E7E6),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reciter.label,
                          style: TextStyle(
                            fontSize: 17,
                            color: isSelected
                                ? const Color(0xFF1A262B)
                                : const Color(0xFF344248),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E6F5A),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: controller.backToIdle,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF08161B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Text('Fermer', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
