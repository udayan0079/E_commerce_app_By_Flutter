/// App-wide constants including strings, asset paths, and dimensions.
class AppConstants {
  // App Information
  static const String appName = 'CraftyBay';
  static const String appVersion = 'Version 1.0';

  // Asset Paths (for local assets placed in assets/images and assets/icons)
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';

  // Default Mock Images (Network placeholders for shoes and categories)
  static const String defaultProductImage =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80';
  static const String shoeBannerImage =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&auto=format&fit=crop&q=80';

  // Screen Padding and Border Radius
  static const double screenPadding = 16.0;
  static const double cardBorderRadius = 10.0;
  static const double buttonBorderRadius = 8.0;
}
