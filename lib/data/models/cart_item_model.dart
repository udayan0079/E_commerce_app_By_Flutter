import 'package:flutter/material.dart';
import 'product_model.dart';

/// Cart item model storing the product, chosen color, chosen size, and quantity.
class CartItemModel {
  String id;
  final ProductModel product;
  final String color;
  final String size;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    this.color = 'Default',
    this.size = 'M',
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    ProductModel prod;
    if (json['product'] is Map) {
      prod = ProductModel.fromJson(Map<String, dynamic>.from(json['product'] as Map));
    } else if (json['product'] is String) {
      prod = ProductModel(
        id: json['product'] as String,
        title: json['product_title']?.toString() ?? 'Product',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['product_img']?.toString() ?? '',
      );
    } else {
      prod = ProductModel.mockProducts.first;
    }

    return CartItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? UniqueKey().toString(),
      product: prod,
      color: json['color']?.toString() ?? 'Default',
      size: json['size']?.toString() ?? 'M',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.id,
      'quantity': quantity,
      'color': color,
      'size': size,
    };
  }

  /// Mock items in cart for testing and previews
  static List<CartItemModel> get mockCartItems => [
        CartItemModel(
          id: 'c1',
          product: ProductModel.mockProducts[0],
          color: 'Red',
          size: 'X',
          quantity: 1,
        ),
        CartItemModel(
          id: 'c2',
          product: ProductModel.mockProducts[1],
          color: 'Blue',
          size: 'M',
          quantity: 2,
        ),
        CartItemModel(
          id: 'c3',
          product: ProductModel.mockProducts[2],
          color: 'Black',
          size: 'L',
          quantity: 1,
        ),
        CartItemModel(
          id: 'c4',
          product: ProductModel.mockProducts[3],
          color: 'Grey',
          size: 'S',
          quantity: 1,
        ),
      ];
}
