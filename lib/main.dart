import 'package:flutter/material.dart';
import 'package:vacc_app/screens/splash/spalsh_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const JuliaApp());
}

class JuliaApp extends StatelessWidget {
  const JuliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Julia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}