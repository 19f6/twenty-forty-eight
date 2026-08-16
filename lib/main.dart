import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundTop,
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
