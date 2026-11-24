import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_constants.dart';
import '../../../app/app_env.dart';
import '../../../app/app_urls.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/cart_service.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../data/services/network_caller.dart';
import '../../widgets/app_logo.dart';
import '../main_bottom_nav/main_bottom_nav_screen.dart';
import 'sign_in_screen.dart';

/// 4-Digit OTP verification screen calling live API: POST /auth/verify-otp
/// Supports automatic clipboard detection, paste auto-distribution, and resend OTP.
class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  int _countdown = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Check clipboard for automatic OTP autofill when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboardForOtp();
    });
  }

  void _startTimer() {
    _countdown = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        if (mounted) setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  /// Automatically check clipboard for 4-digit code
  Future<void> _checkClipboardForOtp() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        final text = clipboardData.text!.trim();
        final match = RegExp(r'\b\d{4}\b').firstMatch(text);
        if (match != null) {
          _fillOtp(match.group(0)!);
        }
      }
    } catch (_) {}
  }

  /// Distributes a 4-digit string across all 4 boxes and auto-triggers verification
  void _fillOtp(String code) {
    if (code.length == 4) {
      for (int i = 0; i < 4; i++) {
        _otpControllers[i].text = code[i];
      }
      _focusNodes[3].requestFocus();
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _otpControllers.map((c) => c.text.trim()).join();
    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call live API: POST /auth/verify-otp
    final response = await NetworkCaller.postRequest(
      url: AppUrls.verifyOtp,
      body: {
        'email': widget.email,
        'otp': otpCode,
      },
    );

    setState(() => _isLoading = false);

    if (response.isSuccess && response.responseData != null) {
      final data = response.responseData['data'];
      if (data is Map) {
        final token = data['token'] ?? '';
        final user = data['user'] ?? {};
        AuthService.setAuthData(token, user is Map<String, dynamic> ? user : {});
        CartService.fetchCart().catchError((_) {});
        WishlistService.fetchWishlist().catchError((_) {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email Verified Successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainBottomNavScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        final errorMsg = response.errorMessage.toLowerCase();

        // If email is already verified on server
        if (errorMsg.contains('already verified') || errorMsg.contains('verified this email before')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already verified! Please sign in with your password.'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(prefilledEmail: widget.email),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    final response = await NetworkCaller.postRequest(
      url: AppUrls.resendOtp,
      body: {'email': widget.email},
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.isSuccess
              ? (response.responseData?['msg'] ?? 'New OTP sent to your email!')
              : response.errorMessage),
          backgroundColor: response.isSuccess ? AppColors.success : AppColors.danger,
        ),
      );
      if (response.isSuccess) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.screenPadding * 1.5),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 90),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter OTP Code',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A 4 Digit OTP Code has been Sent to\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4 digit PIN input row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: 55,
                        height: 55,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length > 1) {
                              _fillOtp(value.trim());
                              return;
                            }
                            if (value.isNotEmpty && index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                            if (index == 3 && value.isNotEmpty) {
                              _verifyOtp();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Auto-fill & Paste Helpers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.paste, size: 16, color: AppColors.primary),
                        label: const Text('Paste Clipboard'),
                        onPressed: _checkClipboardForOtp,
                      ),
                      if (AppEnv.demoOtp.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.bolt, size: 16, color: AppColors.accent),
                          label: const Text('Auto-fill OTP'),
                          onPressed: () => _fillOtp(AppEnv.demoOtp),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : ElevatedButton(
                          onPressed: _verifyOtp,
                          child: const Text('Verify & Proceed'),
                        ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'This code will expire in '),
                        TextSpan(
                          text: '${_countdown}s',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _countdown == 0 ? _resendOtp : null,
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                        color: _countdown == 0 ? AppColors.primary : AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInScreen(prefilledEmail: widget.email),
                        ),
                      );
                    },
                    child: const Text(
                      'Already verified? Sign In with Password',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
