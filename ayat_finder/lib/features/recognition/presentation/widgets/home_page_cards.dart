part of '../pages/home_page.dart';

class _SingleAyahCard extends StatelessWidget {
  const _SingleAyahCard({required this.ayah, required this.transcription});

  final AyahDetection ayah;
  final String transcription;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF2EFE6),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE8E3D6)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '94 % CONFIANCE',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: Color(0xFF8A8F90),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'S${ayah.surahNumber}:${ayah.ayahNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF927B4D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  ayah.arabicText,
                  style: const TextStyle(
                    fontFamily: 'QuranHafs',
                    fontSize: 32,
                    height: 1.7,
                    color: Color(0xFF101A1F),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'TRANSCRIPTION',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2,
                  color: Color(0xFF8A8F90),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transcription.isEmpty
                    ? 'Texte transcrit indisponible.'
                    : transcription,
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontStyle: FontStyle.italic,
                  fontSize: 35,
                  height: 1.35,
                  color: Color(0xFF3F4D53),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SequenceAyahCard extends StatelessWidget {
  const _SequenceAyahCard({required this.ayah});

  final AyahDetection ayah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E8E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEDE3CF),
                child: Text(
                  '${ayah.ayahNumber}',
                  style: const TextStyle(
                    color: Color(0xFF90733F),
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'S${ayah.surahNumber}:${ayah.ayahNumber}',
                style: const TextStyle(color: Color(0xFF6C7579), fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.arabicText,
              style: const TextStyle(
                fontFamily: 'QuranHafs',
                fontSize: 32,
                height: 1.8,
                color: Color(0xFF162126),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final HistoryEntry item;

  @override
  Widget build(BuildContext context) {
    final when = _relativeTime(item.createdAt);
    if (!item.success) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E7E4)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFF3DFD8),
              child: Icon(Icons.close_rounded, color: Color(0xFFB95038)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.errorMessage ?? 'Aucun verset détecté',
                style: const TextStyle(fontSize: 17, color: Color(0xFFAA523D)),
              ),
            ),
            Text(
              when,
              style: const TextStyle(fontSize: 15, color: Color(0xFF7D8588)),
            ),
          ],
        ),
      );
    }

    final result = item.result!;
    final ayahs = result.ayahs;
    final title = ayahs.length > 1
        ? '${_surahName(result.surahNumber ?? ayahs.first.surahNumber)} · ${ayahs.first.ayahNumber} → ${ayahs.last.ayahNumber}'
        : '${_surahName(result.surahNumber ?? ayahs.first.surahNumber)} · ${ayahs.first.ayahNumber}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E7E4)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEFE8D9),
            child: Text(
              'ق',
              style: TextStyle(color: Color(0xFF8F733F), fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF152126),
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    ayahs.first.arabicText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'QuranHafs',
                      fontSize: 26,
                      color: Color(0xFF515C60),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            when,
            style: const TextStyle(fontSize: 15, color: Color(0xFF7D8588)),
          ),
        ],
      ),
    );
  }
}
