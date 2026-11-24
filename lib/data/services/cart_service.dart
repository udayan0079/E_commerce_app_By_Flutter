import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../app/app_urls.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'auth_service.dart';
import 'network_caller.dart';

/// Central cart service managing cart items, syncing with backend when logged in,
/// preserving local cart additions, and providing reactive ValueNotifier.
class CartService {
  static final ValueNotifier<List<CartItemModel>> cartNotifier =
      ValueNotifier<List<CartItemModel>>([]);

  static final ValueNotifier<bool> isBusyNotifier = ValueNotifier<bool>(false);

  static List<CartItemModel> get items => cartNotifier.value;

  static double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  static int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Fetch cart items from live API if user is authenticated without wiping local cart
  static Future<void> fetchCart() async {
    if (!AuthService.isLoggedIn) return;

    try {
      isBusyNotifier.value = true;
      final response = await NetworkCaller.getRequest(
        url: AppUrls.cart,
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

        final serverItems = rawList
            .map((item) {
              if (item is Map) {
                return CartItemModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            })
            .whereType<CartItemModel>()
            .toList();

        // MERGE: Keep any locally added items and merge with server items!
        final Map<String, CartItemModel> merged = {};
        for (final item in cartNotifier.value) {
          merged[item.product.id] = item;
        }
        for (final item in serverItems) {
          merged[item.product.id] = item; // Server item updates or adds
        }

        cartNotifier.value = merged.values.toList();
      }
    } catch (e) {
      log('Error fetching cart: $e');
    } finally {
      isBusyNotifier.value = false;
    }
  }

  /// Add a product to cart (or increment quantity if item exists)
  static Future<bool> addToCart({
    required ProductModel product,
    required String color,
    required String size,
    required int quantity,
  }) async {
    final currentList = List<CartItemModel>.from(cartNotifier.value);
    final existingIndex = currentList.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Increment existing item quantity
      currentList[existingIndex].quantity += quantity;
      cartNotifier.value = List.from(currentList);

      if (AuthService.isLoggedIn && !currentList[existingIndex].id.startsWith('local_')) {
        NetworkCaller.patchRequest(
          url: AppUrls.updateCartItem(currentList[existingIndex].id),
          body: {'quantity': currentList[existingIndex].quantity.toString()},
          token: AuthService.token,
        );
      }
      return true;
    }

    // Create new item with local temporary id
    final newItem = CartItemModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      color: color,
      size: size,
      quantity: quantity,
    );

    currentList.add(newItem);
    cartNotifier.value = currentList;

    // Sync to backend if logged in
    if (AuthService.isLoggedIn) {
      try {
        // Send valid product ID. Only send color/size if the product defines them
        final Map<String, dynamic> body = {
          'product': product.id,
        };
        if (quantity > 1) {
          body['quantity'] = quantity;
        }

        var response = await NetworkCaller.postRequest(
          url: AppUrls.cart,
          body: body,
          token: AuthService.token,
        );

        // Fallback: If server rejects with any validation (e.g. invalid color), retry with only product ID
        if (!response.isSuccess) {
          response = await NetworkCaller.postRequest(
            url: AppUrls.cart,
            body: {'product': product.id},
            token: AuthService.token,
          );
        }

        if (response.isSuccess && response.responseData != null) {
          final data = response.responseData['data'];
          if (data is Map && data['_id'] != null) {
            newItem.id = data['_id'].toString();
          }
        }
      } catch (e) {
        log('Error adding to cart API: $e');
      }
    }

    return true;
  }

  /// Remove item from cart by cart item ID
  static Future<bool> removeFromCart(String cartItemId) async {
    final currentList = List<CartItemModel>.from(cartNotifier.value);
    currentList.removeWhere((item) => item.id == cartItemId);
    cartNotifier.value = currentList;

    if (AuthService.isLoggedIn && !cartItemId.startsWith('local_')) {
      try {
        await NetworkCaller.deleteRequest(
          url: AppUrls.deleteCartItem(cartItemId),
          token: AuthService.token,
        );
      } catch (e) {
        log('Error deleting cart item API: $e');
      }
    }

    return true;
  }

  /// Update item quantity
  static Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    final currentList = List<CartItemModel>.from(cartNotifier.value);
    final index = currentList.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      currentList[index].quantity = newQuantity;
      cartNotifier.value = List.from(currentList);

      if (AuthService.isLoggedIn && !cartItemId.startsWith('local_')) {
        NetworkCaller.patchRequest(
          url: AppUrls.updateCartItem(cartItemId),
          body: {'quantity': newQuantity.toString()},
          token: AuthService.token,
        );
      }
    }
  }

  /// Clear cart
  static void clearCart() {
    cartNotifier.value = [];
  }
}
