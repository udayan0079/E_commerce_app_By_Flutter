import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'app_theme.dart';
import '../presentation/screens/splash/splash_screen.dart';

/// Root application widget configuring MaterialApp with custom theme and initial route.
class CraftyBayApp extends StatelessWidget {
  const CraftyBayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
