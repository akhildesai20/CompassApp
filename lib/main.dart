import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/compass/compass_screen.dart';

void main() => runApp(const CompassApp());

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimalist Compass',
      theme: AppTheme.dark,     // single dark theme for now
      home: const CompassScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
