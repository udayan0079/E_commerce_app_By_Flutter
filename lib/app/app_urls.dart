import 'app_env.dart';

/// Centralized API endpoint registry.
/// Base URL is loaded dynamically from `.env` via [AppEnv.apiBaseUrl].
class AppUrls {
  static String get baseUrl => AppEnv.apiBaseUrl;

  // ---------------- User & Auth ----------------
  static String get login => '$baseUrl/auth/login';
  static String get signup => '$baseUrl/auth/signup';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get resendOtp => '$baseUrl/auth/resend-otp';
  static String get profile => '$baseUrl/auth/profile';

  // ---------------- Sliders & Banners ----------------
  static String get homeSliders => '$baseUrl/slides?count=100';

  // ---------------- Brands & Categories ----------------
  static String get brands => '$baseUrl/brands?count=500';
  static String get categories => '$baseUrl/categories?count=500';
  static String categoryById(String catId) => '$baseUrl/categories/$catId';

  // ---------------- Products ----------------
  static String get products => '$baseUrl/products?count=500';
  static String productById(String id) => '$baseUrl/products/id/$id';
  static String productBySlug(String slug) => '$baseUrl/products/$slug';
  static String productsByCategory(String catId) => '$baseUrl/products?category=$catId&count=500';

  // ---------------- Reviews ----------------
  static String productReviews(String productId) => '$baseUrl/reviews?product=$productId&count=100';
  static String get createReview => '$baseUrl/review';

  // ---------------- Cart ----------------
  static String get cart => '$baseUrl/cart';
  static String updateCartItem(String cartItemId) => '$baseUrl/cart/$cartItemId';
  static String deleteCartItem(String cartItemId) => '$baseUrl/cart/$cartItemId';

  // ---------------- Wishlist ----------------
  static String get wishlist => '$baseUrl/wishlist';
  static String deleteWishlistItem(String wishlistItemId) => '$baseUrl/wishlist/$wishlistItemId';

  // ---------------- Orders ----------------
  static String get orders => '$baseUrl/orders?count=100';
  static String get createOrder => '$baseUrl/order';
  static String cancelOrder(String orderId) => '$baseUrl/orders/$orderId/cancel';
}
