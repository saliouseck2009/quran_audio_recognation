import 'package:flutter/foundation.dart';

@immutable
class ReciterOption {
  const ReciterOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

const List<ReciterOption> kReciterOptions = <ReciterOption>[
  ReciterOption(id: 'ar.alafasy', label: 'Mishary Alafasy'),
  ReciterOption(id: 'ar.abdurrahmaansudais', label: 'Abdurrahman As-Sudais'),
  ReciterOption(id: 'ar.saoodshuraym', label: 'Saood Ash-Shuraym'),
  ReciterOption(id: 'ar.husary', label: 'Mahmoud Khalil Al-Husary'),
  ReciterOption(id: 'ar.hudhaify', label: 'Ali Al-Hudhaify'),
];

const String kDefaultReciterId = 'ar.alafasy';
