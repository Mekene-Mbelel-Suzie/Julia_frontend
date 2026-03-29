// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const VaccApp());
}

class VaccApp extends StatefulWidget {
  const VaccApp({super.key});

  @override
  State<VaccApp> createState() => _VaccAppState();
}

class _VaccAppState extends State<VaccApp> {
  Locale _locale = const Locale('en');

  // Called when user changes language
void setLocale(Locale locale) {
  setState(() {
    _locale = locale;
  });
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaccination App',

      // 🌍 Language
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('de'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🧭 Routing
      initialRoute: '/login',
      routes: {
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => SignupScreen(onLocaleChange: setLocale),
},
    );
  }
}