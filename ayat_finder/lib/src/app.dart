import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ayat_finder/core/di/service_locator.dart';
import 'package:ayat_finder/features/recognition/presentation/cubit/home_cubit.dart';
import 'package:ayat_finder/features/recognition/presentation/pages/home_page.dart';

class AyatFinderApp extends StatelessWidget {
  const AyatFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    const baseBackground = Color(0xFFF8F7F3);
    return MaterialApp(
      title: 'Ayat Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: baseBackground,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0E1D20),
          secondary: Color(0xFFB89A5C),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 32,
            height: 1.04,
            color: Color(0xFF172126),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Times New Roman',
            fontSize: 36,
            height: 1.1,
            color: Color(0xFF172126),
          ),
          bodyLarge: TextStyle(fontSize: 24, color: Color(0xFF172126)),
          bodyMedium: TextStyle(
            fontSize: 18,
            height: 1.4,
            color: Color(0xFF6B7478),
          ),
        ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(0.84)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: BlocProvider<HomeCubit>(
        create: (_) => getIt<HomeCubit>(),
        child: Builder(
          builder: (context) {
            return AyatHomePage(controller: context.read<HomeCubit>());
          },
        ),
      ),
    );
  }
}
