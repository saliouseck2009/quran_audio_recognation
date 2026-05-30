import 'package:ayat_finder/features/recognition/domain/entities/ayah_detection.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class MushafPage extends StatefulWidget {
  const MushafPage({
    super.key,
    required this.ayahs,
    required this.title,
    required this.subtitle,
  });

  final List<AyahDetection> ayahs;
  final String title;
  final String subtitle;

  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  late final List<HighlightVerse> _highlights;
  late final int _initialPageNumber;
  late final PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    _highlights = widget.ayahs
        .map((ayah) {
          final pageNumber = _safePageNumber(ayah.surahNumber, ayah.ayahNumber);
          return HighlightVerse(
            surah: ayah.surahNumber,
            verseNumber: ayah.ayahNumber,
            page: pageNumber,
            color: const Color(0x66D8BD7F),
          );
        })
        .toList(growable: false);

    _initialPageNumber = _highlights.isNotEmpty ? _highlights.first.page : 1;
    _currentPage = _initialPageNumber;
    _pageController = PageController(initialPage: _initialPageNumber - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _safePageNumber(int surahNumber, int ayahNumber) {
    try {
      final page = getPageNumber(surahNumber, ayahNumber);
      if (page < 1) {
        return 1;
      }
      if (page > 604) {
        return 604;
      }
      return page;
    } catch (_) {
      return 1;
    }
  }

  String _surahNameForPage(int pageNumber) {
    try {
      final pageInfo = getPageData(pageNumber);
      if (pageInfo.isNotEmpty) {
        final firstEntry = pageInfo.first;
        if (firstEntry is Map<String, dynamic>) {
          final surahNumber = (firstEntry['surah'] as num?)?.toInt();
          if (surahNumber != null && surahNumber > 0) {
            return getSurahNameArabic(surahNumber);
          }
        }
      }
    } catch (_) {
      // Fallback below.
    }

    return widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final currentSurahName = _surahNameForPage(_currentPage);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFF2EFE6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentSurahName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B363B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Page $_currentPage',
                    style: const TextStyle(
                      color: Color(0xFF6A7377),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: QuranPageView(
                pageController: _pageController,
                highlights: _highlights,
                isDarkMode: Theme.of(context).brightness == Brightness.dark,
                isTajweed: true,
                onPageChanged: (pageNumber) {
                  setState(() {
                    _currentPage = pageNumber;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
