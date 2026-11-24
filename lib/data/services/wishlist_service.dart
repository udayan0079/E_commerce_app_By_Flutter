import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../app/app_urls.dart';
import '../models/product_model.dart';
import 'auth_service.dart';
import 'network_caller.dart';

/// Central wishlist service managing favorited items from the live API (GET /wishlist),
/// supporting instant reactive local toggling and background server sync.
class WishlistService {
  static final ValueNotifier<List<ProductModel>> wishlistNotifier =
      ValueNotifier<List<ProductModel>>([]);

  static final Map<String, String> _productToWishlistId = {};

  /// Instantly checks if a product is in the wishlist based on the reactive product list
  static bool isFavorite(String productId) {
    return wishlistNotifier.value.any((p) => p.id == productId);
  }

  /// Fetch live wishlist from server for authenticated user
  static Future<void> fetchWishlist() async {
    if (!AuthService.isLoggedIn) return;

    try {
      final response = await NetworkCaller.getRequest(
        url: AppUrls.wishlist,
        token: AuthService.token,
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        List rawList = [];
        if (data is Map && data['results'] is List) {
          rawList = data['results'];
        } else if (data is List) {
          rawList = data;
        }

        final List<ProductModel> serverProducts = [];
        for (var item in rawList) {
          if (item is Map) {
            final wishlistItemId = item['_id']?.toString() ?? '';
            final prodJson = item['product'];
            if (prodJson is Map) {
              final prod = ProductModel.fromJson(Map<String, dynamic>.from(prodJson));
              serverProducts.add(prod);
              if (wishlistItemId.isNotEmpty) {
                _productToWishlistId[prod.id] = wishlistItemId;
              }
            }
          }
        }

        // Merge: keep locally added items and combine with server items
        final Map<String, ProductModel> map = {};
        for (final p in wishlistNotifier.value) {
          map[p.id] = p;
        }
        for (final p in serverProducts) {
          map[p.id] = p;
        }

        wishlistNotifier.value = map.values.toList();
      }
    } catch (e) {
      log('Error fetching wishlist: $e');
    }
  }

  /// Toggle product in wishlist (instant local update + background cloud sync)
  static Future<bool> toggleWishlist(ProductModel product) async {
    final productId = product.id;
    final currentlyFav = isFavorite(productId);

    if (currentlyFav) {
      // Remove locally immediately
      wishlistNotifier.value =
          wishlistNotifier.value.where((p) => p.id != productId).toList();
      final wishlistItemId = _productToWishlistId.remove(productId);

      if (AuthService.isLoggedIn && wishlistItemId != null && wishlistItemId.isNotEmpty) {
        try {
          await NetworkCaller.deleteRequest(
            url: AppUrls.deleteWishlistItem(wishlistItemId),
            token: AuthService.token,
          );
        } catch (e) {
          log('Error deleting wishlist item: $e');
        }
      }
      return false; // Removed
    } else {
      // Add locally immediately!
      final updatedList = List<ProductModel>.from(wishlistNotifier.value)..add(product);
      wishlistNotifier.value = updatedList;

      if (AuthService.isLoggedIn) {
        try {
          final response = await NetworkCaller.postRequest(
            url: AppUrls.wishlist,
            body: {'product': productId},
            token: AuthService.token,
          );

          if (response.isSuccess && response.responseData != null) {
            final data = response.responseData['data'];
            if (data is Map && data['_id'] != null) {
              _productToWishlistId[productId] = data['_id'].toString();
            }
          }
        } catch (e) {
          log('Error adding to wishlist API: $e');
        }
      }
      return true; // Added
    }
  }

  /// Clear in-memory wishlist
  static void clearWishlist() {
    _productToWishlistId.clear();
    wishlistNotifier.value = [];
  }
}
