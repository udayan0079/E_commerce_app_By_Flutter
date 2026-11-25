/// Environment configuration supporting optional `--dart-define` /
/// `--dart-define-from-file=.env` overrides while keeping personal credentials
/// out of source control and allowing direct `flutter run` out of the box.
class AppEnv {
  static const String _defaultApiBaseUrl = 'https://ecom-rs8e.onrender.com/api';
  static const String _defaultFallbackReviewProductId = '681372b57aff1010848eea4c';

  static String get apiBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    return envUrl.isNotEmpty ? envUrl : _defaultApiBaseUrl;
  }

  static String get demoEmail => const String.fromEnvironment('DEMO_EMAIL');

  static String get demoPassword => const String.fromEnvironment('DEMO_PASSWORD');

  static String get demoOtp => const String.fromEnvironment('DEMO_OTP');

  static String get fallbackReviewProductId {
    const envId = String.fromEnvironment('FALLBACK_REVIEW_PRODUCT_ID');
    return envId.isNotEmpty ? envId : _defaultFallbackReviewProductId;
  }
}
