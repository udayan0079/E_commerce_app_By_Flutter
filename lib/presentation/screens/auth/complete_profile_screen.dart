import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../main_bottom_nav/main_bottom_nav_screen.dart';

/// Complete Profile Screen for user onboarding.
class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenPadding * 1.5),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Get started with us with your details',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(hintText: 'First Name'),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: 'Last Name'),
                  const SizedBox(height: 12),
                  const CustomTextField(
                    hintText: 'Mobile',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  const CustomTextField(hintText: 'City'),
                  const SizedBox(height: 12),
                  const CustomTextField(
                    hintText: 'Shipping Address',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainBottomNavScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Complete'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
