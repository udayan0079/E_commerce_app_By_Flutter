import 'package:flutter/material.dart';

/// CraftyBay Logo Widget displaying the exact UI branded image assets.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    // For small app bar logo (horizontal icon + text)
    if (size <= 45 && showText) {
      return Image.asset(
        'assets/images/logo_nav.png',
        height: size,
        fit: BoxFit.contain,
      );
    }

    // For vertical full logo (Icon + Text below)
    if (showText) {
      return Image.asset(
        'assets/images/logo.png',
        width: size,
        fit: BoxFit.contain,
      );
    }

    // Icon only (Shopping bag + cursor)
    return Image.asset(
      'assets/images/logo_icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
