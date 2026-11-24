import 'package:flutter/material.dart';
import '../../../app/app_constants.dart';
import '../../../data/services/auth_service.dart';
import '../auth/sign_in_screen.dart';
import '../main_bottom_nav/main_bottom_nav_screen.dart';

/// Pixel-matched Splash Screen according to exact reference design:
/// - Pure white background
/// - Centered CraftyBay Logo from exact asset
/// - Bottom Teal CircularProgressIndicator
/// - Bottom "Version 1.0" subtle text
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final Widget nextScreen = AuthService.isLoggedIn
            ? const MainBottomNavScreen()
            : const SignInScreen();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => nextScreen,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const Spacer(flex: 10),

              // Exact CraftyBay Logo from uploaded reference
              Image.asset(
                'assets/images/logo.png',
                width: 155,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 9),

              // Bottom Progress Indicator
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Color(0xFF07AEAF),
                  strokeWidth: 3.2,
                ),
              ),
              const SizedBox(height: 16),

              // Version 1.0 text
              const Text(
                AppConstants.appVersion,
                style: TextStyle(
                  color: Color(0xFFA0A5AA),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
