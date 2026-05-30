part of '../pages/home_page.dart';

class _StepCard extends StatelessWidget {
  const _StepCard({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9E8)),
      ),
      child: Row(
        children: [
          if (done)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2D6E59),
              size: 24,
            )
          else
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Color(0xFFB89A5C),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 22, color: Color(0xFF2A353A)),
          ),
        ],
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9E8)),
      ),
      child: Text(
        '•  $text',
        style: const TextStyle(fontSize: 20, color: Color(0xFF415055)),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.dark = false,
    this.size = 90,
    this.iconSize = 38,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool dark;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF08161B) : const Color(0xFFF3F2ED),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E4E2)),
        ),
        child: Icon(
          icon,
          color: dark ? Colors.white : const Color(0xFF223238),
          size: iconSize,
        ),
      ),
    );
  }
}

class _WaveBars extends StatefulWidget {
  const _WaveBars();

  @override
  State<_WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<_WaveBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value * 2 * math.pi;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(36, (index) {
              final amp = 0.25 + (math.sin(t + index / 2) + 1) / 2;
              final h = 12 + amp * 28;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: h,
                decoration: BoxDecoration(
                  color: const Color(0xFF29393F),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _OrbWidget extends StatelessWidget {
  const _OrbWidget({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final factor in [1.0, 0.76, 0.54])
            Container(
              width: size * factor,
              height: size * factor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8E7E0)),
              ),
            ),
          Container(
            width: size * 0.44,
            height: size * 0.44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFF5F0DF), Color(0xFFD4BF8A)],
              ),
            ),
          ),
          ...List.generate(8, (index) {
            final angle = index * math.pi / 4;
            final radius = size * (index.isEven ? 0.45 : 0.32);
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            final color = index % 3 == 0
                ? const Color(0xFF7A907F)
                : const Color(0xFFD2B777);
            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: index.isEven ? 14 : 10,
                height: index.isEven ? 14 : 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'à l’instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  return 'il y a ${diff.inDays} j';
}

String _surahName(int surahNumber) {
  const names = <int, String>{
    1: 'Al-Fātiḥa',
    2: 'Al-Baqara',
    3: 'Āl-ʿImrān',
    4: 'An-Nisāʾ',
    5: 'Al-Māʾida',
    6: 'Al-Anʿām',
    7: 'Al-Aʿrāf',
    8: 'Al-Anfāl',
    9: 'At-Tawba',
    10: 'Yūnus',
    11: 'Hūd',
    12: 'Yūsuf',
    13: 'Ar-Raʿd',
    14: 'Ibrāhīm',
    15: 'Al-Ḥijr',
    16: 'An-Naḥl',
    17: 'Al-Isrāʾ',
    18: 'Al-Kahf',
    19: 'Maryam',
    20: 'Ṭā-Hā',
    36: 'Yā-Sīn',
    55: 'Ar-Raḥmān',
    67: 'Al-Mulk',
    97: 'Al-Qadr',
    112: 'Al-Ikhlāṣ',
    113: 'Al-Falaq',
    114: 'An-Nās',
  };

  return names[surahNumber] ?? 'Sourate $surahNumber';
}

String _reciterLabelById(String reciterId) {
  for (final reciter in kReciterOptions) {
    if (reciter.id == reciterId) {
      return reciter.label;
    }
  }
  return kReciterOptions.first.label;
}
