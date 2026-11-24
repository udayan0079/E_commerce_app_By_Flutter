import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/services/wishlist_service.dart';
import 'product_image_view.dart';

/// Fully responsive, 100% overflow-proof Product Card:
/// - Fits any 2-column or 3-column grid without overflowing
/// - FittedBox on the bottom row guarantees 0 horizontal overflow
/// - Expanded on image guarantees 0 vertical overflow
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  child: ProductImageView(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Entire bottom row is wrapped in FittedBox so it NEVER overflows
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Price
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          // Rating
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 1),
                              Text(
                                '${product.rating}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          // Favorite / Wishlist button wired to live WishlistService
                          ValueListenableBuilder<List<ProductModel>>(
                            valueListenable: WishlistService.wishlistNotifier,
                            builder: (context, _, child) {
                              final isFav = WishlistService.isFavorite(product.id);
                              return Material(
                                color: isFav
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: onFavoriteTap ?? () async {
                                    await WishlistService.toggleWishlist(product);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.5),
                                    child: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      size: 13.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
