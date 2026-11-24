import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_urls.dart';
import '../../../data/services/network_caller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_text_field.dart';
import 'otp_verification_screen.dart';
import 'sign_in_screen.dart';

/// Sign Up Screen calling live API: POST /auth/signup
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await NetworkCaller.postRequest(
      url: AppUrls.signup,
      body: {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
      },
    );

    setState(() => _isLoading = false);

    if (response.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.responseData?['msg'] ?? 'OTP sent to your email!',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        final errorMsg = response.errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
          ),
        );

        if (errorMsg.toLowerCase().contains('already') || errorMsg.toLowerCase().contains('exist')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(
                prefilledEmail: _emailController.text.trim(),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding * 1.5),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AppLogo(size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Get Started With Us',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'First Name',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter first name' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Last Name',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter last name' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _phoneController,
                  hintText: 'Mobile Phone',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _cityController,
                  hintText: 'City',
                  prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.primary),
                ),
                const SizedBox(height: 22),
                _isLoading
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('Sign Up & Get OTP'),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
