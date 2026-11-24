import 'package:flutter/material.dart';

/// Centralized color palette for CraftyBay e-commerce application.
/// Keeping all color values in this single class ensures consistent styling
/// and makes changing theme colors simple and readable.
class AppColors {
  // Brand Primary & Accent Colors
  static const Color primary = Color(0xFF07AEAF); // Primary Teal color
  static const Color primaryLight = Color(0xFFE8F7F7); // Soft light teal for card & icon backgrounds
  static const Color primaryDark = Color(0xFF058B8C);

  // Accent and Feedback Colors
  static const Color accent = Color(0xFFFFA000); // Golden Amber for stars/ratings
  static const Color favorite = Color(0xFFFF5252); // Red for favorites/wishlist
  static const Color success = Color(0xFF4CAF50);
  static const Color danger = Color(0xFFE53935);

  // Neutral & Surface Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color cardBg = Color(0xFFF4F9F9); // Light tint for category & product containers

  // Typography Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color textLight = Color(0xFFFFFFFF);

  // Borders and Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocused = Color(0xFF07AEAF);
  static const Color iconColor = Color(0xFF4A5568);
}
