import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/app_colors.dart';

/// Clean and reliable image viewer that uses a web CORS proxy on Flutter Web,
/// provides a subtle progress spinner while loading, and falls back to a neutral
/// icon instead of arbitrary or misleading placeholder pictures.
class ProductImageView extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData placeholderIcon;

  const ProductImageView({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.placeholderIcon = Icons.inventory_2_outlined,
  });

  /// Resolve URL for cross-platform compatibility.
  /// On Flutter Web CanvasKit, external domains without CORS headers are blocked.
  /// Wrapping with images.weserv.nl proxy bypasses the CanvasKit CORS restriction.
  static String resolveUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (kIsWeb && trimmed.startsWith('http') && !trimmed.contains('weserv.nl')) {
      return 'https://images.weserv.nl/?url=${Uri.encodeComponent(trimmed)}';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = resolveUrl(imageUrl);

    if (effectiveUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      effectiveUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.cardBg,
      child: Center(
        child: Icon(
          placeholderIcon,
          color: AppColors.textHint.withValues(alpha: 0.6),
          size: (height != null && height! < 70) ? 20 : 32,
        ),
      ),
    );
  }
}
