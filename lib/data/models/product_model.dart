import 'package:flutter/material.dart';

/// Live Product Model from API /products
class ProductModel {
  final String id;
  final String title;
  final double price;
  final double? regularPrice;
  final double rating;
  final String imageUrl;
  final String description;
  final List<Color> availableColors;
  final List<String> rawColors;
  final List<String> availableSizes;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    this.regularPrice,
    this.rating = 4.8,
    required this.imageUrl,
    this.description = '',
    this.availableColors = const [Colors.teal, Colors.blue, Colors.black],
    this.rawColors = const [],
    this.availableSizes = const ['S', 'M', 'L', 'XL'],
    this.isFavorite = false,
  });

  String getColorName(int index) {
    if (rawColors.isNotEmpty && index < rawColors.length) {
      return rawColors[index];
    }
    if (index < availableColors.length) {
      final c = availableColors[index];
      if (c == Colors.red) return 'Red';
      if (c == Colors.blue) return 'Blue';
      if (c == Colors.green) return 'Green';
      if (c == Colors.purple) return 'Purple';
      if (c == Colors.amber) return 'Amber';
      if (c == Colors.grey) return 'Grey';
      if (c == Colors.black) return 'Black';
      if (c == Colors.teal) return 'Teal';
    }
    return 'Default';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse photos list strictly from API data
    String img = '';
    if (json['photos'] is List && (json['photos'] as List).isNotEmpty) {
      img = json['photos'][0].toString();
    }

    // Parse colors
    List<String> rawColorsList = [];
    List<Color> colors = [Colors.teal, Colors.blue, Colors.black];
    if (json['colors'] is List && (json['colors'] as List).isNotEmpty) {
      rawColorsList = (json['colors'] as List).map((c) => c.toString()).toList();
      colors = (json['colors'] as List).map<Color>((c) {
        final str = c.toString().toLowerCase();
        if (str.contains('red')) return Colors.red;
        if (str.contains('blue')) return Colors.blue;
        if (str.contains('green')) return Colors.green;
        if (str.contains('purple')) return Colors.purple;
        if (str.contains('gold') || str.contains('amber')) return Colors.amber;
        if (str.contains('grey') || str.contains('gray')) return Colors.grey;
        if (str.contains('black')) return Colors.black;
        return Colors.teal;
      }).toList();
    }

    // Parse sizes
    List<String> sizes = ['S', 'M', 'L', 'XL'];
    if (json['sizes'] is List && (json['sizes'] as List).isNotEmpty) {
      sizes = (json['sizes'] as List).map((s) => s.toString()).toList();
    }

    return ProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['current_price'] is num)
          ? (json['current_price'] as num).toDouble()
          : 0.0,
      regularPrice: (json['regular_price'] is num)
          ? (json['regular_price'] as num).toDouble()
          : null,
      rating: 4.8,
      imageUrl: img,
      description: json['description'] ?? 'No description provided.',
      availableColors: colors,
      rawColors: rawColorsList,
      availableSizes: sizes,
      isFavorite: false,
    );
  }

  /// Mock products used as fallback
  static List<ProductModel> get mockProducts => const [
        ProductModel(
          id: 'p1',
          title: 'Happy New Year Special Deal Save 30%',
          price: 100.0,
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
          isFavorite: true,
        ),
        ProductModel(
          id: 'p2',
          title: 'Nike Air Max Running Shoes',
          price: 120.0,
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
          isFavorite: false,
        ),
        ProductModel(
          id: 'p3',
          title: 'Adidas Ultraboost Sneaker',
          price: 95.0,
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
          isFavorite: false,
        ),
        ProductModel(
          id: 'p4',
          title: 'Puma Sports Athletic Shoe',
          price: 85.0,
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
          isFavorite: true,
        ),
      ];
}
