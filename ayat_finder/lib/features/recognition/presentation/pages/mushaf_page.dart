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

  int _surahNumberForPage(int pageNumber) {
    try {
      final pageInfo = getPageData(pageNumber);
      if (pageInfo.isNotEmpty) {
        final firstEntry = pageInfo.first;
        if (firstEntry is Map) {
          final surahNumber = (firstEntry['surah'] as num?)?.toInt();
          if (surahNumber != null && surahNumber > 0) {
            return surahNumber;
          }
        }
      }
    } catch (_) {
      // Fallback below.
    }

    return widget.ayahs.isNotEmpty ? widget.ayahs.first.surahNumber : 1;
  }

  String _surahNameForPage(int pageNumber) {
    try {
      return getSurahNameArabic(_surahNumberForPage(pageNumber));
    } catch (_) {
      return widget.title;
    }
  }

  Future<void> _openSurahPicker() async {
    final selectedSurah = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => _SurahPickerSheet(
        currentSurahNumber: _surahNumberForPage(_currentPage),
      ),
    );

    if (selectedSurah == null || !mounted) {
      return;
    }

    final targetPage = _safePageNumber(selectedSurah, 1);
    await _pageController.animateToPage(
      targetPage - 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _openSurahPicker,
                      child: Row(
                        children: [
                          Flexible(
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
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color(0xFF2B363B),
                          ),
                        ],
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

class _SurahPickerSheet extends StatefulWidget {
  const _SurahPickerSheet({required this.currentSurahNumber});

  final int currentSurahNumber;

  @override
  State<_SurahPickerSheet> createState() => _SurahPickerSheetState();
}

class _SurahPickerSheetState extends State<_SurahPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(int surahNumber) {
    if (_query.isEmpty) {
      return true;
    }

    final q = _query.toLowerCase().trim();
    final english = getSurahNameEnglish(surahNumber).toLowerCase();
    final arabic = getSurahNameArabic(surahNumber).toLowerCase();
    final number = surahNumber.toString();
    return english.contains(q) || arabic.contains(q) || number.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.82;
    final surahNumbers = List<int>.generate(
      totalSurahCount,
      (i) => i + 1,
    ).where(_matchesQuery).toList(growable: false);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDACCA9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INDEX DU CORAN',
                            style: TextStyle(
                              color: Color(0xFF718083),
                              fontSize: 11,
                              letterSpacing: 3.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Sourates',
                            style: TextStyle(
                              fontFamily: 'Times New Roman',
                              fontStyle: FontStyle.italic,
                              fontSize: 24,
                              color: Color(0xFF8F6B2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF0E9D9),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF3C464A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1ECDF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    style: const TextStyle(
                      color: Color(0xFF39484D),
                      fontSize: 16,
                    ),
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une sourate',
                      hintStyle: const TextStyle(color: Color(0xFF9BA3A6)),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF7A868A),
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: surahNumbers.length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, color: Color(0xFFE7E4DB)),
                    itemBuilder: (_, index) {
                      final surahNumber = surahNumbers[index];
                      final englishName = getSurahNameEnglish(surahNumber);
                      final arabicName = getSurahNameArabic(surahNumber);
                      final page = getPageNumber(surahNumber, 1);
                      final isCurrent =
                          surahNumber == widget.currentSurahNumber;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).pop(surahNumber),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              _SurahNumberBadge(
                                number: surahNumber,
                                isCurrent: isCurrent,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  englishName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: const Color(0xFF1E2A2F),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 112,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      arabicName,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontFamily: 'QuranHafs',
                                        fontSize: 26,
                                        color: isCurrent
                                            ? const Color(0xFF8C6A2E)
                                            : const Color(0xFF111D22),
                                      ),
                                    ),
                                    Text(
                                      'Page $page',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6A7377),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahNumberBadge extends StatelessWidget {
  const _SurahNumberBadge({required this.number, required this.isCurrent});

  final int number;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 40,
            color: isCurrent
                ? const Color(0xFFB99655)
                : const Color(0xFFE2D4B3),
          ),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? const Color(0xFFF3E8CA)
                  : const Color(0xFFF7F2E6),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCurrent
                    ? const Color(0xFF7B5F2D)
                    : const Color(0xFF94753D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
