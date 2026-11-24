import 'package:flutter/services.dart';

/// Environment configuration loader reading key=value pairs from `.env`
/// (with optional `--dart-define` fallback) so sensitive URLs and credentials
/// stay out of version control.
class AppEnv {
  static final Map<String, String> _values = {};

  /// Loads environment variables from the bundled `.env` asset.
  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('.env');
      for (final rawLine in raw.split('\n')) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final eqIndex = line.indexOf('=');
        if (eqIndex <= 0) continue;
        final key = line.substring(0, eqIndex).trim();
        var value = line.substring(eqIndex + 1).trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        _values[key] = value;
      }
    } catch (_) {
      // Safe fallback when `.env` is absent (e.g., unit tests or CI).
    }
  }

  static String get(String key, {String fallback = ''}) {
    final loaded = _values[key];
    if (loaded != null && loaded.isNotEmpty) return loaded;
    return fallback;
  }

  static String get apiBaseUrl => get(
        'API_BASE_URL',
        fallback: const String.fromEnvironment('API_BASE_URL'),
      );

  static String get demoEmail => get(
        'DEMO_EMAIL',
        fallback: const String.fromEnvironment('DEMO_EMAIL'),
      );

  static String get demoPassword => get(
        'DEMO_PASSWORD',
        fallback: const String.fromEnvironment('DEMO_PASSWORD'),
      );

  static String get demoOtp => get(
        'DEMO_OTP',
        fallback: const String.fromEnvironment('DEMO_OTP'),
      );

  static String get fallbackReviewProductId => get(
        'FALLBACK_REVIEW_PRODUCT_ID',
        fallback: const String.fromEnvironment('FALLBACK_REVIEW_PRODUCT_ID'),
      );
}
